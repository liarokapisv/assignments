
fun accessSpace vec (y,x) =
  String.sub(Vector.sub(vec, y), x)


fun neighbors (height, width) space (y,x) =
let 
  fun boundsCheck (y,x) = 
    y >= 0 andalso y < height andalso x >= 0 andalso x < width
  fun valid (y,x) = boundsCheck (y,x) andalso accessSpace space (y,x) <> #"X"
  fun costTo (y', x') = 
    if x' > x then 1
    else if y' > y then 1
    else if x' < x then 2
    else 3
in
  List.map (fn n => (costTo n, n)) 
    (List.filter valid [(y,x-1),(y,x+1),(y-1,x),(y+1,x)])
end



fun searchFor (height, width) vec c =
let
  fun searchForCol c y x =
    if x = width then NONE
    else if accessSpace vec (y,x) = c then SOME (y,x)
    else searchForCol c y (x+1)
  fun searchForRow c y =
    case (searchForCol c y 0) of
         NONE => searchForRow c (y+1)
       | SOME (y',x') => (y', x')
in
  searchForRow c 0
end



fun access (height, width) arr (y,x) =
  Array.sub(arr, y*width + x)

fun update (height, width) arr (y,x) new =
  (Array.update(arr, y*width + x, new); arr)

fun empty (height, width) v = Array.tabulate (height*width, fn _ => v)


fun solveProblem maxweight neighbors distance updateDistance updatePrevious info start =
let 
  val queue = Array.fromList ([start] :: List.tabulate (maxweight-1, fn _ => []))
  fun pathsN info = 
    if Array.all List.null queue
    then info 
    else let
      fun rotateQueue _ = Array.modifyi (fn (i,_) => 
        if i+1 < Array.length queue 
        then Array.sub(queue, i+1)
        else []) queue
      val curNodes = Array.sub(queue,0)
      val _ = rotateQueue ()
      fun queueBetterAlternatives (node, info) =
      let
        fun queueIfBetter ((weight, neighbor),info) =
        let
          val curDist = distance info neighbor
          val alternateDist = weight + distance info node
        in
          if alternateDist < curDist then 
            let
              val info' = updateDistance info neighbor alternateDist
              val info'' = updatePrevious info' neighbor node
            in
              (Array.update(queue, weight-1, neighbor :: Array.sub(queue,
              weight-1)); 
              info'')
            end
          else
            info
        end
      in 
        List.foldl queueIfBetter info (neighbors node)
      end
    in
      pathsN (List.foldl queueBetterAlternatives info curNodes)
    end
in
  pathsN info
end


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


fun toDirections path =
let
  fun toDirection ((y1,x1),(y2,x2)) =
    if x1 < x2 then #"R"
    else if x1 > x2 then #"L"
    else if y1 < y2 then #"D"
    else #"U"
in
  String.implode (map toDirection (ListPair.zip (path,List.tl path)))
end

fun iteratePath f start finish = 
  if start = finish then [finish]
  else (start :: iteratePath f (f start) finish)

fun main _ = 
let
  val args = CommandLine.arguments ()
  val fileName = List.hd args
  val (bounds, space) = readfile fileName
  val neighbors' = neighbors bounds space 
  val previouses = empty bounds bounds
  val distances = empty bounds (Option.valOf Int.maxInt)
  fun distance (_, distances) = access bounds distances
  fun updatePrevious (previouses, distances) k v = (update bounds previouses k v, distances)
  fun updateDistance (previouses, distances) k v = (previouses, update bounds distances k v)
  val info = (previouses, distances)
  val start = searchFor bounds space #"S"
  val finish = searchFor bounds space #"E"
  val info' = solveProblem 3 neighbors' distance updateDistance updatePrevious (updateDistance info start 0) start
  val (previouses', distances') = info'
  val path = rev (iteratePath (access bounds previouses') finish start)
  val directions = toDirections path
  val distance = distance info' finish
in
  print (Int.toString distance ^ " " ^ directions ^ "\n")
end;

main (); 
