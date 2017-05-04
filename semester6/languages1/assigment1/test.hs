
import qualified Data.Map as M
import Data.List

type Node = (Bool, Int, Int)
type PathInfo = M.Map Node (Int, [Node])
type Contents = M.Map Node Char

visited :: PathInfo -> Node -> Bool
visited info node = M.member node info 

update :: PathInfo -> Node -> (Int, [Node]) -> PathInfo
update info node content = M.insert node content info

empty :: PathInfo
empty = M.empty


search2d:: (Char -> Bool) -> [String] -> Node
search2d pred lines = searchStart' lines 0
    where searchStart' (line : lines) i = 
            case (Data.List.findIndex pred line) of
                 Nothing -> searchStart' lines (i+1)
                 Just j -> (False, i, j)

searchStart = search2d (=='S')

searchEnd = search2d (=='E')


checkBounds :: (Int, Int) -> Node -> Bool
checkBounds (height, width) (_,y,x) =
    y >= 0 && y < height && x >= 0 && x < width

neighbors :: (Int, Int) -> [String] -> Node -> [(Int, Node)]
neighbors bounds contents (z,y,x)
    | ((contents !! y) !! x) == 'W' = (1, (not z, y, x)) : neighbs_with_cost
    | otherwise = neighbs_with_cost
    where neighbs_with_cost | z == False = map (\x -> (2,x)) neighbs
                            | otherwise = map (\x -> (1,x)) neighbs
          neighbs = filter valid [(z,y+1,x), (z,y-1,x), (z,y,x+1), (z,y,x-1)]
          valid (z,y,x) = checkBounds bounds (z,y,x) && ((contents !! y) !! x) /= 'X'

solve_problem :: (Node -> [(Int, Node)]) -> 
                 (PathInfo -> Node -> Bool) -> 
                 (PathInfo -> Node -> (Int, [Node]) -> PathInfo) -> 
                 PathInfo ->
                 Node -> 
                 PathInfo

solve_problem neighbors visited update empty start = result
    where (result, _, _) = head $ dropWhile (\(_, x, y) -> not (null x && null y)) $ iterate paths_n (empty, [(start, 0, [start])], [])
          paths_n :: (PathInfo, [(Node, Int, [Node])], [(Node, Int, [Node])]) -> (PathInfo, [(Node, Int, [Node])], [(Node, Int, [Node])])
          paths_n (info, paths_cur, paths_next) = (info', paths_cur', paths_next')
             where (info', new_paths_cur) = foldr update_if_unvisited (info, []) paths_cur
                   update_if_unvisited :: (Node, Int, [Node]) -> (PathInfo, [(Node, Int, [Node])]) -> (PathInfo, [(Node, Int, [Node])])
                   update_if_unvisited (node, dist, path) (info, paths) = 
                        if not $ visited info node 
                            then (update info node (dist, path), (node, dist, path) : paths)
                            else (info, paths)
                   paths_cur' = map strip_cost neighboring_paths_cost1 ++ paths_next
                   paths_next' = map strip_cost neighboring_paths_cost2 
                   strip_cost (_,n,d,p) = (n,d,p)
                   (neighboring_paths_cost1, neighboring_paths_cost2) = Data.List.partition (\(d,_,_,_) -> d == 1) all_neighboring_paths
                   all_neighboring_paths = concatMap neighboring_paths new_paths_cur
                   neighboring_paths (node, dist, path) = map (\(d,n) -> (d, n , dist + d, n : path)) (neighbors node)

main = do
   contents <- getContents
   let space = lines contents
       height = length space
       width = length (space !! 0)
       start = searchStart space
       end = searchEnd space
       info = solve_problem (neighbors (height,width) space) visited update empty start
   print (info M.! end)
   
    
