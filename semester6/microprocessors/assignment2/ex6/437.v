module half_adder(x, y, S, C);
    input x, y;
    output S, C;

    assign S = x ^ y;
    assign C = x & y;
endmodule

module full_adder(x,y,z,S,C);
    input x, y, z;
    output S, C;
    wire w1, w2, w3;

    half_adder h1(.x(x), .y(y), .S(w1), .C(w2));
    half_adder h2(.x(w1), .y(z), .S(S), .C(w3));
    assign C = w2 | w3;
endmodule

module adder_4bit(c, A, B, S, C);
    input wire c;
    input wire [3:0] A, B;
    output wire [3:0] S;
    output wire C;
    wire [3:0] Cs;

    full_adder fa(A[0], B[0], c, S[0], Cs[0]);

    genvar i;
    generate
    for (i = 1; i < 4; i=i+1) begin
        full_adder fa(A[i], B[i], Cs[i-1], S[i], Cs[i]);
    end
    endgenerate

    assign C = Cs[3];
endmodule

module addsuber_4bit(M, A, B, S, C);
    input wire M;
    input wire [3:0] A, B;
    output wire [3:0] S;
    output wire C;
    wire [3:0] Ws;

    genvar i;
    generate
    for (i = 0; i < 4; i = i + 1) begin
        xor(Ws[i], B[i], M);
    end
    endgenerate

    adder_4bit adder(M, A, Ws, S, C);
endmodule

