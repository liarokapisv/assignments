:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(readutil)).

get_array(Array, I, V) :-
    arg(I, Array, V).

set_array(Array, I, V) :-
    nb_setarg(I, Array, V), !.

get_array2d(Array, I-J, V) :-
    get_array(Array, I, A),
    get_array(A, J, V).

set_array2d(Array, I-J, V) :-
    get_array(Array, I, A),
    set_array(A, J, V), !.

init_array(Array, N, V) :-
    length(Array_, N),
    maplist(=(V), Array_),
    Array =.. [array|Array_], !.

init_array2d(Array, H-W, V) :-
    length(Array_, H),
    maplist(init_array_(W, V), Array_),
    Array =.. [array | Array_], !.

read_input(File, N, K, B, Steps, Broken) :-
    open(File, read, Stream),
    read_line(Stream, [N, K, B]),
    read_line(Stream, Steps),
    read_line(Stream, Broken), !.

read_line(Stream, List) :-
    read_line_to_codes(Stream, Line),
    ( Line = [] -> List = []
    ; atom_codes(A, Line),
    atomic_list_concat(As, ' ', A),
    maplist(atom_number, As, List)
    ).

sum_mod(Xs, R) :-
    sum_mod_(Xs, R, 0), !.

sum_mod_([], R, R) :- !.
sum_mod_([X|Xs], R, A) :-
    A_ is (A + X) mod 1000000009,
    sum_mod_(Xs, R, A_).


set_array_(A, V, I) :- set_array(A, I, V), !.
get_array_(A, V, I) :- get_array(A, I, V).

sub(A,B,C) :- C is A-B.

prev_stairs(Steps, S, PrevStairs) :-
    maplist(sub(S), Steps, PrevStairs), !.

create_valid_stairs(N, Broken, ValidStairs) :-
    init_array(ValidStairs, N, true),
    maplist(set_array_(ValidStairs, false), Broken), !.

valid_stair(N, ValidStairs, S) :-
    S > 0,
    S =< N,
    get_array(ValidStairs, S, true), !.

valid_prev_stairs(N, Steps, ValidStairs, S, ValidPrevStairs) :-
    prev_stairs(Steps, S, PrevStairs),
    include(valid_stair(N, ValidStairs), PrevStairs, ValidPrevStairs), !.
                        

hopping_(_, _, 1, 1) :- !.
hopping_(MemoedHopping, ValidPrevStairs, N, Answer) :-
    get_array(MemoedHopping, N, Answer_),
    (Answer_ is -1 -> 
        get_array(ValidPrevStairs, N, PrevStairs),
        maplist(hopping_(MemoedHopping, ValidPrevStairs), PrevStairs, PrevWays),
        sum_mod(PrevWays, Answer),
        set_array(MemoedHopping, N, Answer)
    ;
        Answer is Answer_
    ), !.
    
hopping(File, Answer) :-
    read_input(File, N, _, _, Steps, Broken),
    create_valid_stairs(N, Broken, ValidStairs),
    numlist(1,N, Stairs),
    maplist(valid_prev_stairs(N, Steps, ValidStairs), Stairs, ValidPrevStairs_),
    ValidPrevStairs =.. [array | ValidPrevStairs_],
    init_array(MemoedHopping, N, -1),
    maplist(hopping_(MemoedHopping, ValidPrevStairs), Stairs, _),
    hopping_(MemoedHopping, ValidPrevStairs, N, Answer), !.

    
