
val readInt = TextIO.scanStream (Int.scan StringCvt.DEC)

val height = Option.valOf (readInt TextIO.stdIn)
val _ = TextIO.inputLine TextIO.stdIn

val contents = 
  let
    fun contents' 0 = []
      | contents' n =
          case (TextIO.inputLine TextIO.stdIn) of
               NONE => []
             | SOME line => line :: (contents' (n-1))
  in
    Array.fromList (contents' height)
  end
 
fun readContents (i : int) (j : int) : char =
  String.sub(Array.sub(contents, i), j)

val width = String.size (Array.sub (contents, 0))

val distances = Array.tabulate (2 * height * width, fn x => (~1, []))

fun readDistances (k : bool, i : int, j : int) : (int * (bool * int * int) list) =
  case k of
       true => Array.sub (distances, height * width + height * i + j)
     | false => Array.sub (distances, height * i + j)

fun writeDistances(k : bool, i : int, j : int) (x :(int * (bool * int * int) list)) : unit =
  case k of
       true => Array.update (distances, height * width + height * i + j, x)
     | false => Array.update (distances, height * i + j, x)

fun neighbors (pos : bool * int * int) : (bool * int * int) list = 
  let 
    val i = #2 pos
    val j = #3 pos 
    val k = #1 pos
    fun pred (k, i, j) = ((i >= 0 andalso i < height) andalso
                          (j >= 0 andalso j < width) andalso
                          (readContents i j <> #"X"))
    val tmp = List.filter pred [(k, i+1, j), (k, i-1, j), (k, i, j-1), (k, i, j+1)]
  in
    if readContents i j = #"W" then (not k, i, j) :: tmp else tmp
  end

fun distance (k1,i1,j1) (k2,i2,j2) : int =
  if k1 = false andalso k2 = false then 2
  else 1

val limit = 2

val queue : (((int * (bool * int * int) * ((bool * int * int) list) ) Queue.queue) Array.array) =
  Array.tabulate (limit+1, fn _ => Queue.mkQueue ())

fun readQueue (n : int) : (int * (bool * int * int) * ((bool * int * int) list)) Queue.queue
  = Array.sub(queue, n)

fun rotate arr = 
  if Array.length arr = 0 then ()
  else 
    let 
      val head = Array.sub (arr, 0)
      val len = Array.length arr
    in
      List.app (fn i => Array.update(arr, i, Array.sub(arr, i+1))) (List.tabulate (len-1, fn k => k ));
      Array.update(arr, len-1, head)
    end

fun findi_opt (pred : 'a -> 'b option) (arr : 'a Array.array) : (int * 'b) option =
  let
    fun step (i, x, acc) = 
        case acc of
             NONE => (case pred x of
                          NONE => NONE
                        | SOME y => SOME (i, y))
           | SOME y => SOME y
  in
    Array.foldli step NONE arr
  end

fun cherry_pick (i, (j, _)) = (false, i, j)

val start = cherry_pick (Option.valOf (findi_opt (fn row =>  CharVector.findi (fn (_,c) => c = #"S") row) contents))

val target = cherry_pick (Option.valOf (findi_opt (fn row => CharVector.findi (fn (_,c) => c = #"E") row) contents))

fun shortest_distance (start : (bool * int * int)) (target : (bool * int * int)) : (int * ((bool * int * int) list))  = (
  Queue.enqueue(readQueue 0, (0, start, [start]));
  while Array.exists (fn x => not (Queue.isEmpty x)) queue do (
    let 
      val cur_visit = readQueue 0
    in
      while not (Queue.isEmpty cur_visit) do (
        let
          val (cur_dist, cur_pos, cur_path) = Queue.dequeue cur_visit
          fun update_distance neighb =
            if #1 (readDistances neighb)= ~1 then
              let
                val dist = distance cur_pos neighb
              in
                Queue.enqueue(readQueue dist, (cur_dist + dist, neighb, neighb :: cur_path))
              end
            else
              ()
        in
          if #1 (readDistances cur_pos) = ~1 then 
            (writeDistances cur_pos (cur_dist, cur_path);
            List.app update_distance (neighbors cur_pos))
          else ()
        end 
      );
      rotate queue
    end
  );
  readDistances target)

fun to_directions (rpath : (bool * int * int) list) : string =
  let 
    val path = rev rpath
    val p1 = path
    val p2 = tl path
    val ziped = ListPair.zip (p1, p2)
    fun to_direction ((z1,y1,x1),(z2,y2,x2)) =
      if (z1 <> z2) then #"W"
      else if (y1 < y2) then #"D"
      else if (y1 > y2) then #"U"
      else if (x1 < x2) then #"R"
      else #"L"
  in
    String.implode (map to_direction ziped)
  end



val r = (shortest_distance start target);
val dist = #1 r;
val dir = to_directions (#2 r);
print (Int.toString dist ^ " " ^ dir ^ "\n");



