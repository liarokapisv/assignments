
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


(* Returns the first node whose value equals the given character *)

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

fun accessInfo (height, width) arr (z,y,x) =
  if z then Array.sub(arr, height*width + y*width + x)
  else Array.sub(arr, y*width + x)


(* Used to update the info regarding the best path of a given node. 
 * This could return unit but returning the updated container makes our
 * solveProblem function able to work with immutable data structures so it's
 * a bit more general. *)

fun update (height, width) arr (z,y,x) new =
  if z then (Array.update(arr, height*width + y*width + x, new); arr)
  else (Array.update(arr, y*width + x, new); arr)


(* Checks if we have found the best path to a given node *)

fun visited bounds info pos = (#1 (accessInfo bounds info pos : int * (bool * int * int) list)) <> Option.valOf Int.maxInt


(* Creates an empty array that will contain the info regarding the best path to
 * each node. Ideally we would like to have something similar to Clojure's
 * vector type but this should do. *)

fun empty (height, width) = Array.tabulate (2*height*width, fn _ => (Option.valOf Int.maxInt, []))


(* This is the function that does most of the work.
 *
 * First, some definitions:
 * - The tail of a path is the path that results if we remove the last node of 
 *   the given path.
 * - A 1-diff path is a path whose tail's total distance differs by 1
 * - A 2-diff path is a path whose tail's total distance differs by 2
 *
 * The logic behind the function is that given:
 * - All best paths of length i
 * - All best 2-diff paths of length (i+1)
 * It is possible to find:
 * - All best paths of length (i+1)
 * - All best 2-diff paths of length (i+2)
 * 
 * Proof: For a weight limit of 2, any best path is either 1-diff or
 * 2-diff and it's tail is itself a best path.
 * By taking all neighbors of the last node of every best path of length i,
 * we are bound to find all 1-diff best paths of length (i+1) and all 2-diff best
 * paths of length (i+2). We already have the 2-diff best paths of length
 * (i+1) and the union of the 2-diff and 1-diff best paths of length (i+1) gives
 * us all best paths of length (i+1).
 *
 * Note: This can be generalized to a O(k*n) algorithm where n is the number of
 * nodes and k is the heightest weight in the graph divided by the gcd of all
 * weights. 
 *
 * The pathsN function performs the above inductive step with a few small
 * modifications: The function also has to keep track of best paths and a few filtering steps
 * must be applied in order to remove non-best paths.
 *)

fun solveProblem neighbors visited update empty start = 
let 
  fun pathsN (info, [], []) = info
    | pathsN (info, pathsCur, pathsNext) =  
  let
    fun neighboringPaths (node, dist, path) = map (fn (d,n) => (d, n, dist + d, n :: path)) (neighbors node)
    fun updateIfUnvisited ((node, dist, path),(info, paths)) =
      if not (visited info node) 
        then (update info node (dist, path), (node, dist, path) :: paths)
        else (info, paths)
    val (info', newPathsCur) = List.foldl updateIfUnvisited (info, []) pathsCur
    val allNeighboringPaths = List.filter (fn (_,n,_,_) => not (visited info' n)) (List.concat (map neighboringPaths newPathsCur))
    val (neighboringPathsCost1, neighboringPathsCost2) = List.partition (fn (d,_,_,_) => d = 1) allNeighboringPaths
    fun stripCost (_,n,d,p) = (n,d,p)
    val pathsNext' = map stripCost neighboringPathsCost2
    val pathsCur' = map stripCost neighboringPathsCost1 @ pathsNext
  in
    pathsN (info', pathsCur', pathsNext')
  end
in
  pathsN (empty, [(start, 0, [start])], [])
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
  val start = searchFor bounds space #"S"
  val target = searchFor bounds space #"E"
  val info = solveProblem neighbors' visited' update' empty' start
  val result = accessInfo bounds info target
  val dist = #1 result
  val directions = toDirections (rev (#2 result))
in
  print ((Int.toString dist) ^ " " ^ directions ^ "\n")
end;

main (); 
