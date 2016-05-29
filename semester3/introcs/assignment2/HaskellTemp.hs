{-# LANGUAGE BangPatterns #-}

import Control.Monad
import System.Random

fastExpMod :: Integer -> Integer -> Integer -> Integer
fastExpMod b e m = fastExpMod' b e 1
  where 
    fastExpMod' !b 0 !a = a
    fastExpMod' b e a 
      | even e = fastExpMod' (b'^2) (e `div` 2) a
      | odd  e = fastExpMod' (b'^2) ((e-1) `div` 2) (a*b' `mod` m)
      where b' = b `mod` m

check :: Integer -> IO Bool
check n = do 
  alphas <- replicateM 40 $ randomRIO (2, n-1)
  return $ all (\a -> fastExpMod a (n-1) n == 1) alphas
