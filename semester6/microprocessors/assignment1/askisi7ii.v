module askisi7ii(D,X,Y,V);
    input [0:3] D;
    output X,Y,V;
    reg X, Y, V;
    always @(D) begin
        casex (D)
            4'b0000: {X, Y, V} = 3'bxx0;
            4'b1000: {X, Y, V} = 3'b001;
            4'bx100: {X, Y, V} = 3'b011;
            4'bxx10: {X, Y, V} = 3'b101;
            4'bxxx1: {X, Y, V} = 3'b111;
            default: {X, Y, V} = 3'b000;
        endcase
    end
endmodule


