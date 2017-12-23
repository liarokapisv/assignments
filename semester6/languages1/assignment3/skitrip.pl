:- use_module(library(lists)).
:- use_module(library(readutil)).
:- use_module(library(apply)).

read_input(File, N, Heights) :-
    open(File, read, Stream),
    read_line(Stream, [N]),
    read_line(Stream, Heights).

read_line(Stream, List) :-
    read_line_to_codes(Stream, Line),
    ( Line = [] -> List = []
    ; atom_codes(A, Line),
    atomic_list_concat(As, ' ', A),
    maplist(atom_number, As, List)
    ).

zip_list([], [], []) :- !.
zip_list([X|Xs], [Y|Ys], [X-Y|Zs]) :-
    zip_list(Xs, Ys, Zs), !.

foldl(_, [], V0, V0) :- !.
foldl(F, [X|Xs], V0, R) :-
    call(F, X, V0, V1),
    foldl(F, Xs, V1, R), !.

keep_if_gt(X-XI, (Y-YI)-CR, R) :-
    (X > Y -> R = (X-XI)-[X-XI| CR] 
            ; R = (Y-YI)-CR), !.

keep_if_lt(X-XI, (Y-YI)-CR, R) :-
    (X < Y -> R = (X-XI)-[X-XI| CR]
            ; R = (Y-YI)-CR), !.


left_sequence([], []) :- !.
left_sequence([Z|Zs], R) :-
    foldl(keep_if_lt, Zs, Z-[Z], _-R_), 
    reverse(R_, R), !.

right_sequence([], []) :- !.
right_sequence(Zs, R) :-
    reverse(Zs, [Z_|Z_s]),
    foldl(keep_if_gt, Z_s, Z_-[Z_], _-R), !.

maximize_distance(L, R, Answer) :-
    maximize_distance_(L, R, 0, Answer), !.
maximize_distance_([],_, M, M) :- !.
maximize_distance_(_,[], M, M) :- !.
maximize_distance_([X-_|Xs], [Y-YI|Ys], M, Answer) :-
    X > Y,
    maximize_distance_(Xs, [Y-YI|Ys], M, Answer), !.
maximize_distance_([X-XI|Xs], [_-YI|Ys], M, Answer) :-
    D is YI - XI,
    (D > M -> maximize_distance_([X-XI|Xs], Ys, D, Answer)
            ; maximize_distance_([X-XI|Xs], Ys, M, Answer)), !.


skitrip(File, Answer) :-
    read_input(File, N, Heights),
    numlist(1, N, Ns),
    zip_list(Heights, Ns, ZHeights),
    left_sequence(ZHeights, L),
    right_sequence(ZHeights, R),
    maximize_distance(L,R,Answer).


