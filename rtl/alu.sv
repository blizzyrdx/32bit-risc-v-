module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  op,
    output logic [31:0] y,
    output logic        zero
);
    localparam logic [3:0]
        ALU_ADD = 4'd0,
        ALU_SUB = 4'd1,
        ALU_AND = 4'd2,
        ALU_OR  = 4'd3,
        ALU_XOR = 4'd4,
        ALU_SLT = 4'd5;

    always_comb begin
        unique case (op)
            ALU_ADD: y = a + b;
            ALU_SUB: y = a - b;
            ALU_AND: y = a & b;
            ALU_OR : y = a | b;
            ALU_XOR: y = a ^ b;
            ALU_SLT: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default: y = 32'd0;
        endcase
    end

    assign zero = (y == 32'd0);
endmodule
