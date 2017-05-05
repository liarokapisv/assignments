
(* Used to access the geometry *)

fun accessSpace vec (y,x) =
  String.sub(Vector.sub(vec, y), x)


(* Returns the neighbors of a single node *)

fun neighbors (height, width) space (z, y,x) =
let 
  fun boundsCheck (y,x) = 
    y >= 0 andalso y < height andalso x >= 0 andalso x < width
  fun valid (z,y,x) = boundsCheck (y,x) andalso accessSpace space (y,x) <> #"X"
  val neighbs = List.filter valid [(z,y,x-1),(z,y,x+1),(z,y-1,x),(z,y+1,x)];
  val neighbsWithCost = if z = false
                          then map (fn c => (2, c)) neighbs
                          else map (fn c => (1, c)) neighbs
in
  if accessSpace space (y,x) = #"W" then (1, (not z, y, x)) :: neighbsWithCost
  else neighbsWithCost
end


(* Returns the position of a node that satisfies the given predicate *)

fun searchFor (height, width) vec c =
let
  fun searchForCol c y x =
    if x = width then NONE
    else if accessSpace vec (y,x) = c then SOME (y,x)
    else searchForCol c y (x+1)
  fun searchForRow c y =
    case (searchForCol c y 0) of
         NONE => searchForRow c (y+1)
       | SOME (y',x') => (false, y', x')
in
  searchForRow c 0
end


(* Used to retrieve the info regarding the best path to a given node *)

fun accessInfo (height, width) vec (z,y,x) =
  if z then Vector.sub(vec, height*width + y*width + x)
  else Vector.sub(vec, y*width + x)


(* Used to update the info regarding the best path of a given node *)

fun update (height, width) vec (z,y,x) new =
  if z then Vector.update(vec, height*width + y*width + x, new)
  else Vector.update(vec, y*width + x, new)


(* Checks if we have found the best path to a given node *)

fun visited bounds info pos = (#1 (accessInfo bounds info pos : int * (bool * int * int) list)) <> Option.valOf Int.maxInt


(* Creates an empty vector that will contain the info regarding the best path to
 * each node *)

fun empty (height, width) = Vector.tabulate (2*height*width, fn _ => (Option.valOf Int.maxInt, []))


(* This is the function that does most of the work.
 * The logic behind the function is that given all visited nodes, all nodes with best
 * distance i and some nodes with best distance (i+1), it's possible to find all nodes
 * of best distance (i+1) and some nodes of best distance (i+2). In general, this can be
 * further generalized to a O(k*n) algorithm where n is the number of nodes 
 * and k is the the max weight of the graph divided by the gcd of all weights. *)

fun solveProblem neighbors visited update empty start = 
let 
  fun pathsN (info, pathsCur, pathsNext) = 
  let
    fun neighboringPaths (node, dist, path) = map (fn (d,n) => (d, n, dist + d, n :: path)) (neighbors node)
    fun updateIfUnvisited ((node, dist, path),(info, paths)) =
      if not (visited info node) 
        then (update info node (dist, path), (node, dist, path) :: paths)
        else (info, paths)
    val (info', newPathsCur) = foldr updateIfUnvisited (info, []) pathsCur
    val allNeighboringPaths = List.concat (map neighboringPaths newPathsCur)
    val (neighboringPathsCost1, neighboringPathsCost2) = List.partition (fn (d,_,_,_) => d = 1) allNeighboringPaths
    fun stripCost (_,n,d,p) = (n,d,p)
    val pathsNext' = map stripCost neighboringPathsCost2 
    val pathsCur' = map stripCost neighboringPathsCost1 @ pathsNext
  in
    (info', pathsCur', pathsNext')
  end
  fun repeatWhile pred f x = 
    if pred x then repeatWhile pred f (f x) 
    else x
  val (result, _, _) = repeatWhile (fn (_, x, y) => not (null x andalso null y)) pathsN (empty, [(start, 0, [start])], [])
in
  result
end


(* Handles the file reading, returns the bounds and the vector representing our
 * geometry *)

fun readfile name = 
let
  val infile = TextIO.openIn name
  fun readfile' _ =
    case (TextIO.inputLine infile) of
         NONE => []
       | SOME ln => ln :: readfile' ()
  val contents = readfile' ()
  val bounds = (List.length contents, String.size (List.hd contents) - 1)
in
  (bounds, Vector.fromList contents)
end


(* Converts adjacent nodes to a direction character *)

fun toDirections path = 
let
  fun toDirection ((z1,y1,x1),(z2,y2,x2)) =
    if z1 <> z2 then #"W"
    else if x1 < x2 then #"R"
    else if x1 > x2 then #"L"
    else if y1 < y2 then #"D"
    else #"U"
in
  String.implode (map toDirection (ListPair.zip (path,List.tl path)))
end

fun main _ = 
let
  val args = CommandLine.arguments ()
  val fileName = List.hd args
  val (bounds, space) = readfile fileName
  val neighbors' = neighbors bounds space 
  val visited' = visited bounds
  val update' = update bounds 
  val empty' = empty bounds
  val start' = searchFor bounds space #"S"
  val target' = searchFor bounds space #"E"
  val info = solveProblem neighbors' visited' update' empty' start'
  val result = accessInfo bounds info target'
  val dist = #1 result
  val directions = toDirections (rev (#2 result))
in
  print ((Int.toString dist) ^ " " ^ directions ^ "\n")
end;

main ();
