module data_ram #(
    parameter integer WORDS = 256
) (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,
    output logic [31:0] debug_word0
);
    logic [31:0] mem [0:WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            mem[i] = 32'd0;
    end

    always_ff @(posedge clk) begin
        if (we && (addr[31:2] < WORDS))
            mem[addr[31:2]] <= wdata;
    end

    always_comb begin
        if (addr[31:2] < WORDS)
            rdata = mem[addr[31:2]];
        else
            rdata = 32'd0;
    end

    assign debug_word0 = mem[0];
endmodule
