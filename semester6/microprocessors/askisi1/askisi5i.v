module sxhma320a(A, B, C, D, F);
    input A, B, C, D;
    output F;
    wire w1, w2, w3, w4;
    and (w1, C, D);
    and (w2, B, ~C);
    or (w3, w1, B);
    and (w4, w3, A);
    or (F, w4, w2);
endmodule

module sxhma321b(A, B, C, D, F);
    input A, B, C, D;
    output F;
    wire w1, w2, w3, w4, w5;
    nand (w1, A, ~B);
    nand (w2, ~A, B);
    or (w3, C, ~D);
    or (w4, ~w1, ~w2);
    and (w5, w4, w3);
    not (F, w5);
endmodule

module sxhma324(A, B, C, D, E, F);
    input A, B, C, D, E;
    output F;
    wire w1, w2;
    or (w1, A, B);
    or (w2, C, D);
    and (F, w1, w2, ~E);
endmodule

module sxhma325(A, B, C, D, F);
    input A, B, C, D;
    output F;
    wire w1, w2, w3, w4;
    and (w1, A, ~B);
    and (w2, ~A, B);
    or (w3, C, ~D);
    or (w4, w1, w2);
    and (F, w4, w3);
endmodule


