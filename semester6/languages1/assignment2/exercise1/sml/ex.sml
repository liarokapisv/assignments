fun readfile name =
let
  fun scanN 0 scanner stream = []
    | scanN n scanner stream = 
      case (TextIO.scanStream scanner stream) of
           NONE => []
         | SOME x => x :: scanN (n-1) scanner stream
  fun readInts n = scanN n (Int.scan StringCvt.DEC)
  val infile = TextIO.openIn name
  val [N, M, K] = readInts 3 infile
  fun roads _  = 
    case (readInts 2 infile) of
          [r1, r2] => (r1, r2) :: roads ()
        | _ => []
in
  ((N,M,K), roads ())
end 

datatype Elem = Elem of (int * int ref * (Elem option) ref)

fun makeSet id = Elem (id, ref 0, ref NONE)

fun find x =
let
  val Elem (id, _, parent) = x
in
  case !parent of
       NONE => x
     | SOME p => find p
end

fun union (x, y) =
let 
  val xRoot = find(x)
  val yRoot = find(y)
  val Elem (xRootId, xRootRank, xRootParent) = xRoot
  val Elem (yRootId, yRootRank, yRootParent) = yRoot
in
  if xRoot = yRoot then
    ()
  else
    if !xRootRank < !yRootRank then
      xRootParent := SOME yRoot
    else if !xRootRank > !yRootRank then
      yRootParent := SOME xRoot
    else
      (yRootParent := SOME xRoot;
      yRootRank := !xRootRank + 1)
end

fun solveProblem N K roads =
let
  val villages = Array.fromList (map makeSet (List.tabulate (N, fn i => i+1)))
  val _ = map (fn (r1, r2) => union (Array.sub(villages, r1-1), Array.sub(villages, r2-1))) roads
  fun countAndConnect (newVillage, (NONE, networks)) = (SOME newVillage, networks+1)
    | countAndConnect (newVillage, (SOME networkRepresentative, networks)) =
      let 
        val newVillageRoot = find newVillage
        val networkRepresentativeRoot = find networkRepresentative
      in
        if newVillageRoot = networkRepresentativeRoot then
          (SOME networkRepresentative, networks)
        else
          (union (newVillageRoot, networkRepresentativeRoot);
           (SOME networkRepresentative, networks + 1))
      end
  val (_, networks) = Array.foldl countAndConnect (NONE, 0) villages
  val networksAfterBuildingAllRoads = networks - K
in
  if networksAfterBuildingAllRoads > 1 then
    networksAfterBuildingAllRoads
  else
    1
end

fun main _ =
let
  val args = CommandLine.arguments ()
  val fileName = List.hd args
  val ((N,M,K), roads) = readfile fileName
in
  print (Int.toString (solveProblem N K roads) ^ "\n")
end

val _ = main ()
