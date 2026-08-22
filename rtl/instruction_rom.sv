module instruction_rom #(
    parameter integer WORDS = 256,
    parameter string  HEX_FILE = "programs/demo.hex"
) (
    input  logic [31:0] addr,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            mem[i] = 32'h0000_0013; // NOP = ADDI x0,x0,0
        $readmemh(HEX_FILE, mem);
    end

    always_comb begin
        if (addr[31:2] < WORDS)
            rdata = mem[addr[31:2]];
        else
            rdata = 32'h0010_0073; // EBREAK outside ROM
    end
endmodule
