:- dynamic space/2.
:- dynamic best_distance/2.
:- dynamic previous/2.
:- dynamic height/1.
:- dynamic width/1.
:- dynamic queue/2.
:- dynamic queue_length/1.


set_best_distance( K, V) :-
retractall(best_distance(K, _)),
assertz(best_distance(K, V)), !.

set_space(I-J,V) :-
retractall(space(I-J,_)),
assertz(space(I-J,V)), !.

set_previous(I-J, V) :-
retractall(previous(I-J,_)),
assert(previous(I-J,V)), !.

set_queue(I, V) :-
retractall(queue(I,_)),
assert(queue(I,V)), !.

valid(I-J) :-
height(Height),
width(Width),
I >= 0,
I < Height,
J >= 0,
J < Width,
space(I-J,V),
\+ (V = 'X'), !.

neighbors(I-J, N) :-
Ip is I-1,
In is I+1,
Jp is J-1,
Jn is J+1,
include(valid, [I-Jp, I-Jn, Ip-J, In-J], N_),
maplist(call(cost, I-J), N_, Cs),
pairs_keys_values(N, Cs, N_), !.

cost(I0-J0, I1-J1, C) :- 
J1 > J0 -> C = 1 ;
I1 > I0 -> C = 1 ;
J1 < J0 -> C = 2 ;
C = 3, !.



read_lines(Stream, []) :-
at_end_of_stream(Stream), !.
read_lines(Stream, [Line | Lines]) :-
read_line_to_codes(Stream, Line_),
maplist(char_code, Line, Line_),
read_lines(Stream, Lines), !.

construct_map(Space) :-
width(Width),
Width_ is Width-1,
numlist(0,Width_, WIs),
construct_map_(Space, 0, WIs), !.

const(X,_,X) :- !.

construct_map_([], _, _) :- !.
construct_map_([S|Ss], HI, WIs) :-
map_list_to_pairs(call(const, HI), WIs, Ps),
maplist(set_space, Ps, S),
HI_ is HI+1,
construct_map_(Ss, HI_, WIs), !.

init(Set, V) :-
height(Height),
width(Width),
init_(Set, 0, 0, Height, Width, V), !.

init_(_,Height, _, Height, _, _) :- !.
init_(Set, I, Width, Height, Width, V) :- 
I_ is I+1,
init_(Set, I_, 0, Height, Width, V), !.
init_(Set, I, J, Height, Width, V) :-
call(Set,I-J,V),
J_ is J+1,
init_(Set, I, J_, Height, Width, V), !.

foldl(_, [], V0, V0) :- !.
foldl(F, [X|Xs], V0, R) :-
call(F, X, V0, V1),
foldl(F, Xs, V1, R), !.

create_queue(M) :-
assertz(queue_length(M)),
M_ is M-1,
numlist(0,M_,Ns),
maplist(const([]), Ns, Empty),
maplist(set_queue, Ns, Empty), !.

queue_is_not_empty :-
queue(_, V),
\+ (V = []), !.

left_shift_queue :-
queue_length(M),
M_ is M-1,
left_shift_queue_(0, M_),
set_queue(M_, []), !.

left_shift_queue_(H ,H) :- !.
left_shift_queue_(L, H) :-
L_ is L+1,
queue(L_,V),
set_queue(L,V),
left_shift_queue_(L_,H), !.

queue_if_better(CurNode, Weight-Neighbor) :-
best_distance(Neighbor, NeighborDistance),
best_distance(CurNode, CurDistance),
AlternativeDistance is Weight + CurDistance,
( AlternativeDistance < NeighborDistance ->
    set_best_distance(Neighbor, AlternativeDistance),
    set_previous(Neighbor, CurNode),
    Weight_ is Weight-1,
    queue(Weight_, ToVisit),
    set_queue(Weight_, [Neighbor | ToVisit])
    ;
    true
), !.

queue_better_alternatives(CurNode) :-
neighbors(CurNode, Neighbors),
maplist(queue_if_better(CurNode), Neighbors), !.

paths_n :-
(queue_is_not_empty ->
    queue(0, CurNodes),
    left_shift_queue,
    maplist(queue_better_alternatives, CurNodes),
    paths_n
    ;
    true
), !.

read_input(File) :-
open(File, read, Stream),
read_lines(Stream, Space),
length(Space, Height),
assertz(height(Height)),
[S|_] = Space,
length(S, Width),
assertz(width(Width)),
construct_map(Space), !.

reconstruct_path(CurPath, Path) :-
height(Height),
width(Width),
CurPath = [First | _],
previous(First, P),
(P = Height-Width ->
    Path = CurPath
    ; 
    Path_ = [P | CurPath],
    reconstruct_path(Path_, Path)
), !.

convert_to_directions([], []) :- !.
convert_to_directions([_],[]) :- !.
convert_to_directions(P, [D|DR]) :-
[X|R1] = P,
[Y|_] = R1,
XI-XJ = X,
YI-YJ = Y,
(YI > XI -> D = 'D' ;
    YI < XI -> D = 'U' ;
    YJ > XJ -> D = 'R' ;
    D = 'L'),
convert_to_directions(R1, DR), !.

moredeli(File, Cost, Path) :-
read_input(File),
height(Height),
width(Width),
M is (Height + Width)*4,
init(set_best_distance, M),
init(set_previous, Height-Width),
space(Start, 'S'),
create_queue(3),
set_queue(0, [Start]),
set_best_distance(Start, 0),
paths_n,
space(End, 'E'),
best_distance(End, Cost),
reconstruct_path([End], Path_),
convert_to_directions(Path_, Path), !.



