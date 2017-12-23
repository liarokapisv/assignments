module ex447 (A,B,C,D, F1, F2);
    input A, B, C, D;
    output F1, F2;

    assign F1 = (~A & ~B & ~C & D) |
                (~A & ~B & C & D) |
                (~A & B & ~C & ~D) |
                (A & ~B & C & D) |
                (A & B & ~C & ~D) |
                (A & B & ~C & D) |
                (A & B & C & ~D) |
                (A & B & C & D)

    assign F2 = (~A & ~B & ~C & D) |
                (~A & ~B & C & ~D) |
                (~A & B & ~C & D) |
                (~A & B & C & D) |
                (A & ~B & ~C & ~D) |
                (A & ~B & C & ~D) |
                (A & ~B & C & D) |
                (A & B & ~C & D) |
                (A & B & C & D)
endmodule
