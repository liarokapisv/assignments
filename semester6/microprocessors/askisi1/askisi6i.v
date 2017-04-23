module askisi6i(X, Y, F);
    input X, Y;
    output F;
    wire w1, w2, w3, w4;
    not #4 (w1, X);
    not #4 (w2, Y);
    and #8 (w3, X, w2);
    and #8 (w4, Y, w1);
    or #10 (F, w3, w4);
endmodule
