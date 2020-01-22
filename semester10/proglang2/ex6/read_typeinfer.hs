{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Data.Char
import System.IO
import Text.Read
import Control.Monad.State.Class
import Control.Monad.Except
import Control.Monad.State.Strict
import Control.Monad
import Control.Applicative
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Control.Monad.Reader.Class
import Control.Monad.Reader
import Control.Monad.Except
import Data.List (nub)

data Type  =  Tvar Int | Tfun Type Type                        
    deriving (Ord, Eq)

data Expr  =  Evar String | Eabs String Expr | Eapp Expr Expr  
    deriving (Ord, Eq)

always = True    -- False omits parentheses whenever possible

instance Show Expr where
  showsPrec p (Evar x) = (x ++)
  showsPrec p (Eabs x e) =
    showParen (always || p > 0) ((("\\" ++ x ++ ". ") ++) . showsPrec 0 e)
  showsPrec p (Eapp e1 e2) =
    showParen (always || p > 1) (showsPrec 1 e1 . (" " ++) . showsPrec 2 e2)

-- Parsing of expressions

instance Read Expr where
  readPrec = (do Ident x <- lexP
                 return (Evar x)) <++
             (do Punc "(" <- lexP
                 Punc "\\" <- lexP
                 Ident x <- lexP
                 Symbol "." <- lexP
                 e <- readPrec
                 Punc ")" <- lexP
                 return (Eabs x e)) <++
             (do Punc "(" <- lexP
                 e1 <- readPrec
                 e2 <- readPrec
                 Punc ")" <- lexP
                 return (Eapp e1 e2))

-- Pretty printing of types

instance Show Type where
  showsPrec p (Tvar alpha) = ("@" ++) . showsPrec 0 alpha
  showsPrec p (Tfun sigma tau) =
    showParen (p > 0) (showsPrec 1 sigma . (" -> " ++) . showsPrec 0 tau)


newtype Subst = Subst (Map.Map Int Type)
  deriving (Eq, Ord, Show, Monoid)

nullSubst = Subst $ Map.empty

-- Note: order of composition matters
composeSubst s1@(Subst m1) s2@(Subst m2) = Subst ((Map.map (apply s1) m2) `Map.union` m1)

class Substitutable a where
  apply :: Subst -> a -> a
  ftv   :: a -> Set.Set Int

instance Substitutable a => Substitutable [a] where
  apply = map . apply
  ftv   = foldr (Set.union . ftv) Set.empty

instance Substitutable Type where
  apply (Subst s) t@(Tvar a) = Map.findWithDefault t a s
  apply s (t1 `Tfun` t2) = apply s t1 `Tfun` apply s t2

  ftv (Tvar n) = Set.singleton n
  ftv (t1 `Tfun` t2) = ftv t1 `Set.union` ftv t2


newtype NameGenState = NameGenState Int

class HasNameGenState a where
    getNameGenState :: a -> NameGenState
    setNameGenState :: NameGenState -> a -> a

instance HasNameGenState NameGenState where
    getNameGenState = id
    setNameGenState = const

fresh :: (MonadState s m, HasNameGenState s) => m Type
fresh = do (NameGenState n) <- gets getNameGenState
           modify $ setNameGenState (NameGenState $ n+1)
           pure $ Tvar n


newtype TypeEnv = TypeEnv (Map.Map String Type)

remove :: TypeEnv -> String -> TypeEnv
remove (TypeEnv env) var = TypeEnv (Map.delete var env)

extend :: TypeEnv -> String -> Type -> TypeEnv
extend (TypeEnv env) s t = TypeEnv $ Map.insert s t env

instance Substitutable TypeEnv where
  apply s (TypeEnv env) = TypeEnv $ Map.map (apply s) env
  ftv (TypeEnv env) = ftv $ Map.elems env

newtype Infer a = Infer { 
    getInfer :: (StateT NameGenState
                (ReaderT TypeEnv
                (Either String))
                a)
    } deriving (Functor, Applicative, Monad, MonadState NameGenState, MonadError String, MonadReader TypeEnv)

bindVar :: Int -> Type -> Infer Subst
bindVar u t | t == Tvar u = pure nullSubst
            | u `Set.member` ftv t = throwError "type error" 
            | otherwise = pure $ Subst $ Map.singleton u t

unify :: Type -> Type -> Infer Subst
unify (Tfun l r) (Tfun l' r') = do subst1 <- unify l l'
                                   subst2 <- unify (apply subst1 r) (apply subst1 r')
                                   pure $ subst2 `composeSubst` subst1 
unify (Tvar u) t = bindVar u t
unify t (Tvar u) = bindVar u t

infer :: Expr -> Infer (Subst, Type)
infer (Evar n) = do (TypeEnv env) <- ask 
                    case Map.lookup n env of
                      Nothing -> throwError "type error"
                      Just t -> pure (nullSubst, t)

infer (Eabs n e) = do t <- fresh
                      let scope e = extend e n t
                      (subst, t1) <- local scope (infer e)
                      pure (subst, (apply subst t) `Tfun` t1)
infer (Eapp e1 e2) = do t <- fresh
                        (subst1, t1) <- infer e1
                        let scope = apply subst1
                        (subst2, t2) <- local scope (infer e2)
                        subst3 <- unify (apply subst2 t1) (Tfun t2 t)
                        pure (subst3 `composeSubst` subst2 `composeSubst` subst1, apply subst3 t)

runInfer :: Expr -> Either String Type
runInfer e = fmap snd $ runReaderT (evalStateT (getInfer $ infer e) (NameGenState 0)) (TypeEnv Map.empty)


data MakeOrderedState = MakeOrderedState
    { oGen :: Int
    , oMap :: Map.Map Int Int
    } 

makeOrdered :: Type -> Type
makeOrdered t = evalState (go t) $ MakeOrderedState { oGen = 0, oMap = Map.empty }
    where go (Tvar n) = do m <- gets oMap
                           case Map.lookup n m of
                            Nothing -> do n' <- gets oGen
                                          modify $ \s -> s { oGen = n' + 1,
                                                             oMap = Map.insert n n' m }
                                          pure $ Tvar n'
                            Just k -> pure $ Tvar k
          go (Tfun t1 t2) = Tfun <$> go t1 <*> go t2

                                            

count n m  =  sequence_ $ take n $ repeat m

main :: IO ()
main =  do n <- readLn
           count n $ do s <- getLine
                        let e = read s :: Expr
                        case runInfer e of
                            Left err -> putStrLn err
                            Right t -> print $ makeOrdered t
                    
