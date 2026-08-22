module regfile (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        write_en,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    output logic [31:0] debug_x10
);
    logic [31:0] regs [0:31];
    integer i;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else begin
            if (write_en && (rd != 5'd0))
                regs[rd] <= write_data;
            regs[0] <= 32'd0;
        end
    end

    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];
    assign debug_x10  = regs[10];
endmodule
