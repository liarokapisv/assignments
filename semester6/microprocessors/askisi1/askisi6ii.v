module askisi334(A, B, C, D, Out_1,Out_2, Out_3);
    input A,B,C,D;
    output Out_1, Out_2, Out_3;
    assign Out_1 = (A | ~B) & ~C & (C | D);
    assign Out_2 = ((~C & D) | (B & C & D) | (C & ~D)) & (~A | B);
    assign Out_3 = (A & B | C) & D | (~B & C);
endmodule
