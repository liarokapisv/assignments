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

shift_array(Array, Width, V) :-
    shift_array_(Array, 1, Width, V), !.

shift_array_(Array, Width, Width, V) :-
    set_array(Array, Width, V), !.

shift_array_(Array, W, Width, V) :-
    W_ is W+1,
    get_array(Array, W_, V0),
    set_array(Array, W, V0),
    shift_array_(Array, W_, Width, V), !.

all_array(Array, P) :-
    forall(get_array(Array, _, V), V = P), !.
    
valid(Height-Width, Space, I-J) :-
    I >= 1,
    I =< Height,
    J >= 1,
    J =< Width,
    get_array2d(Space, I-J, V),
    \+ (V = 'X'), !.

neighbors(Height-Width, Space, I-J, N) :-
    Ip is I-1,
    In is I+1,
    Jp is J-1,
    Jn is J+1,
    include(valid(Height-Width, Space), [I-Jp, I-Jn, Ip-J, In-J], N_),
    maplist(cost(I-J), N_, Cs),
    pairs_keys_values(N, Cs, N_), !.

read_lines(Stream, []) :-
    at_end_of_stream(Stream), !.
read_lines(Stream, [Line | Lines]) :-
    read_line_to_codes(Stream, Line_),
    maplist(char_code, Line2, Line_),
    Line =.. [array|Line2],
    read_lines(Stream, Lines), !.

read_input(File, Height-Width, Space) :-
    open(File, read, Stream),
    read_lines(Stream, Space_),
    length(Space_, Height),
    [S|_] = Space_,
    S =.. [array|S_],
    length(S_, Width),
    Space =.. [array | Space_], !.

queue_if_better(Queue, BestDistance, Previous, CurNode, Weight-Neighbor) :-
    get_array2d(BestDistance, Neighbor, NeighborDistance),
    get_array2d(BestDistance, CurNode, CurDistance),
    AlternativeDistance is Weight + CurDistance,
    (AlternativeDistance < NeighborDistance ->
        set_array2d(BestDistance, Neighbor, AlternativeDistance),
        set_array2d(Previous, Neighbor, CurNode),
        get_array(Queue, Weight, ToVisit),
        set_array(Queue, Weight, [Neighbor | ToVisit])
    ;
        true
    ), !.

queue_better_alternatives(Queue, Height-Width, Space, BestDistance, Previous, CurNode) :-
    neighbors(Height-Width, Space, CurNode, Neighbors),
    maplist(queue_if_better(Queue, BestDistance, Previous, CurNode), Neighbors), !.

cost(I0-J0, I1-J1, C) :- 
    J1 > J0 -> C = 1 ;
    I1 > I0 -> C = 1 ;
    J1 < J0 -> C = 2 ;
    C = 3, !.

paths_n(Queue, Height-Width, Space, BestDistance, Previous) :-
    QueueSize is 3,
    (all_array(Queue, []) ->
        true
    ;
        get_array(Queue, 1, CurNodes),
        shift_array(Queue, QueueSize, []),
        maplist(queue_better_alternatives(Queue, Height-Width, Space, BestDistance, Previous), CurNodes),
        paths_n(Queue, Height-Width, Space, BestDistance, Previous)
    ), !.

reconstruct_path(Previous, Height-Width, CurPath, Path) :-
    CurPath = [First | _],
    get_array2d(Previous, First, P),
    Hp is Height+1,
    Wp is Width+1,
    L = Hp-Wp,
    (P = L->
        Path = CurPath
    ; 
        Path_ = [P | CurPath],
        reconstruct_path(Previous, Height-Width, Path_, Path)
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
    read_input(File, Height-Width, Space),
    M is (Height + Width)*4,
    init_array2d(BestDistances, Height-Width, M),
    Hp is Height+1,
    Wp is Width+1,
    L = Hp-Wp,
    init_array2d(Previous, Height-Width, L),
    get_array2d(Space, Start, 'S'),
    get_array2d(Space, End, 'E'),
    init_array(Queue, 3, []),
    set_array(Queue, 1, [Start]),
    set_array2d(BestDistances, Start, 0),
    paths_n(Queue, Height-Width, Space, BestDistances, Previous),
    get_array2d(BestDistances, End, Cost),
    reconstruct_path(Previous, Height-Width, [End], Path_),
    convert_to_directions(Path_, Path), !.

    

