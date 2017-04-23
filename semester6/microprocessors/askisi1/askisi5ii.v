module sxhma320b(A, B, C, D, F);
    input A, B, C, D;
    output F;
    assign F = A & (C & D  | B) | B & ~C;
endmodule

module sxhma321a(A, B, C, D, F);
    input A, B, C, D;
    output F;
    assign F = (A & ~B | ~A & B) & (C | ~D);
endmodule

module sxhma324(A, B, C, D, E, F);
    input A, B, C, D, E;
    output F;
    assign F = (A | B) & (C + D) & E;
endmodule

module sxhma325(A, B, C, D, F);
    input A, B, C, D;
    output F;
    assign F = (A & ~B | ~A & B) & (C | ~D);
endmodule


