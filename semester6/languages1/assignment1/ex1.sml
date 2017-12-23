
(* Simple wrapper arround TextIO.scanStream. *)

val scan1 = TextIO.scanStream


(* Scans multiple values. *)

fun scanN 0 scanner stream = []
  | scanN n scanner stream = 
    case (scan1 scanner stream) of
         NONE => []
       | SOME x => x :: scanN (n-1) scanner stream


(* Single decimal integer reader. *)

fun readInt stream = Option.valOf (scan1 (Int.scan StringCvt.DEC) stream)


(* Multiple decimal integers reader. *)

fun readInts n = scanN n (Int.scan StringCvt.DEC)


(* Given a comparator and an initial value, greedily selects successive 
 * greatest elements from the left and reverses the resulting list. 
 *
 * examples: greedAscending (op >) Int.minInt [5,3,7,2,8,1,0] = [8,7,5]
 *           greedAscending (op >) Int.minInt 
 *              [78, 88, 64, 94, 17, 91, 57, 69, 38, 62, 13, 17, 35, 15, 20, 15] = [94, 88, 87]
 *           greedAscending (op <) Int.maxInt [5,3,7,2,8,1,0] = [0,1,2,3,5]
 *           greedAscending (op <) Int.maxInt 
 *              [78, 88, 64, 94, 17, 91, 57, 69, 38, 62, 13, 17, 35, 15, 20, 15]
 *              = [13,17,64,78]
 **)

fun greedAscending greater curMax xs =
  let
    fun greedAscending' greater acc curMax [] = acc
      | greedAscending' greater acc NONE (x :: xs) = 
          greedAscending' greater (x :: acc) (SOME x) xs  
      | greedAscending' greater acc (SOME curMax) (x :: xs) = 
          if greater x curMax 
          then greedAscending' greater (x :: acc) (SOME x) xs 
          else greedAscending' greater acc (SOME curMax) xs
  in
    (greedAscending' greater [] curMax xs)
  end


(* Given a list and it's length, creates a list of element-index pairs.
 * 
 * examples: zipList 9 [5,4,6,3,7,2,8,1,9] = 
 *              [(5,0), (4,1), (6,2), (3,3), (7,4), (2,5), (8,6), (1,7), (9,8)]  
 **)

fun zipList n xs = ListPair.zip (xs, List.tabulate (n, fn x => x ))


(* Given a list, retrieves successive greatest elements from the right. 
 *
 * examples: rightSequence [4,3,5,2,6,8,6,9,5,0,2] = [9,5,2]
 *           rightSequence [1,8,2,3,5,2,4,3,1] = [9,5,4,3,1]
 **)

val rightSequence = let fun greater (x : (int * int))  (y : (int * int)) = #1 x > #1 y 
                        in (greedAscending greater NONE) o rev end

(* Given a list, retrieves successive smallest elements from the left.
 *
 * examples: leftSequence [6,7,4,5,6,3,9,0,8] = [6,4,3,0]
 *           leftSequence [9,8,2,3,5,2,4,3,1] = [9,8,2,1] 
 **)

val leftSequence = let fun lesser (x : (int * int)) (y : (int * int)) = #1 x < #1 y
                         in rev o (greedAscending lesser NONE) end


(* Given two lists of (value * position) elements - one retrieved via leftSequence 
 * and one via rightSequence - , finds a pair of two elements (one from each list) 
 * such that their position difference is maximal and greater than the 
 * initial value, otherwise returns the initial value.
 *
 * examples: maximizeDistance 0 
 *              [(6,0), (5,3), (2, 5)]
 *              [(8,3), (6,7), (5, 10)] = 5
 *           maximizeDistance 0 
 *              [(8,0), (7,6),(5,3),(3,6),(2,8)]
 *              [(11,3),(9,5),(5,7),(3,8),(2,9)] = 4
 **)

fun maximizeDistance curMax [] _ = curMax
  | maximizeDistance curMax _ [] = curMax 
  | maximizeDistance curMax lseq rseq = 
      let 
        val (lval, lindex) :: lrest = lseq
        val (rval, rindex) :: rrest = rseq
      in  
        if lval > rval then maximizeDistance curMax lrest rseq
        else if rindex - lindex > curMax then maximizeDistance (rindex - lindex) lseq rrest
        else maximizeDistance curMax lseq rrest 
      end
      

(* Simple compositional function. As the name suggests, it utilizes the above 
 * functions to solve our problem *)

fun solveProblem n xs = 
  let 
    val zipped = zipList n xs
    val lseq = leftSequence zipped
    val rseq = rightSequence zipped
  in
    maximizeDistance 0 lseq rseq
  end

(* Below we read our given file and print the found solution *)

val args = CommandLine.arguments ();
val stream = TextIO.openIn (List.nth (args, 0));
val n = readInt stream;
val xs = readInts n stream;
print (Int.toString (solveProblem n xs) ^ "\n");
