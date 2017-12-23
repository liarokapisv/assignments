module counter (out, load, up, down, in, reset, clock);
    output reg [3:0] out;
    input load, up, down, carry_in, reset, clock;
    input [3:0] in;

    always @ (posedge clock, negedge reset) begin
        case (1'b1) 
            ~reset: out <= 4'b0000;
            load: out <= in;
            up: out <= out + 1'b1;
            down: out <= out - 1'b1;
        endcase
    end

endmodule

module ex638 (out, in, select, reset, clock);
    output wire [3:0] out;
    input wire [3:0] in;
    input wire [1:0] select;
    input wire reset, clock;

    reg [2:0] counter_inputs;

    counter ctr(out, counter_inputs[2], counter_inputs[1], counter_inputs[0], in, reset, clock);

    always @ (select)
        case (select)
            2'b00: counter_inputs <= 3'b000;
            2'b01: counter_inputs <= 3'b001;
            2'b10: counter_inputs <= 3'b010;
            2'b11: counter_inputs <= 3'b100;
        endcase

endmodule
