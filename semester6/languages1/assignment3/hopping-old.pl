:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(readutil)).

:- dynamic invalid_stair/1.
:- dynamic valid_prev_stairs/2.
:- dynamic memoed_hopping/2.

read_input(File, N, K, B, Steps, Broken) :-
open(File, read, Stream),
read_line(Stream, [N, K, B]),
read_line(Stream, Steps),
read_line(Stream, Broken).

read_line(Stream, List) :-
read_line_to_codes(Stream, Line),
( Line = [] -> List = []
    ; atom_codes(A, Line),
    atomic_list_concat(As, ' ', A),
    maplist(atom_number, As, List)
).

init_invalid_stairs([]) :- !.
init_invalid_stairs([B|Bs]) :-
assertz(invalid_stair(B)),
init_invalid_stairs(Bs), !.

valid_stair(N) :-
N >= 1,
( invalid_stair(N) -> false
    ; true
),!.

init_valid_prev_stairs(N, Steps) :- 
L is N+1,
init_valid_prev_stairs_(1, L, Steps), !.

sub(X,Y,R) :- R is X-Y.

init_valid_prev_stairs_(L, L, _) :- !.
init_valid_prev_stairs_(N, L, Steps) :-
maplist(call(sub, N), Steps, NewStairs),
include(valid_stair, NewStairs, ValidNewStairs),
assertz(valid_prev_stairs(N, ValidNewStairs)),
N_ is N+1,
init_valid_prev_stairs_(N_, L, Steps), !.

hopping(File, Answer) :-
read_input(File, N, K, B, Steps, Broken),
init_invalid_stairs(Broken),
init_valid_prev_stairs(N, Steps),
hopping_(N, Answer), !.

sum_mod(Xs, R) :-
sum_mod_(Xs, R, 0), !.

sum_mod_([], R, R) :- !.
sum_mod_([X|Xs], R, A) :-
A_ is (A + X) mod 1000000009,
sum_mod_(Xs, R, A_).

hopping_(1, 1) :- !.
hopping_(N, Answer) :-
memoed_hopping(N, Answer) ; 
(
    valid_prev_stairs(N, PrevStairs),
    maplist(hopping_, PrevStairs, PrevWays),
    sum_mod(PrevWays, Answer),
    assertz(memoed_hopping(N,Answer))
), !.

init_memoed_hoppings(N) :-
N_ is N+1,
init_memoed_hoppings_(1,N_), !.

init_memoed_hoppings_(H,H) :- !.
init_memoed_hoppings_(L, H) :-
hopping_(L,_),
L_ is L+1,
init_memoed_hoppings_(L_, H), !.

