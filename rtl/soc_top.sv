module soc_top #(
    parameter string PROGRAM_HEX = "programs/demo.hex"
) (
    input  logic        clk,
    input  logic        reset_n,
    output logic        halted,
    output logic        trap,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_x10,
    output logic [31:0] debug_mem0
);
    logic [31:0] imem_addr;
    logic [31:0] imem_rdata;
    logic        dmem_we;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [31:0] dmem_rdata;

    rv32i_core u_core (
        .clk        (clk),
        .reset_n    (reset_n),
        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),
        .dmem_we    (dmem_we),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_rdata (dmem_rdata),
        .halted     (halted),
        .trap       (trap),
        .debug_pc   (debug_pc),
        .debug_x10  (debug_x10)
    );

    instruction_rom #(
        .HEX_FILE(PROGRAM_HEX)
    ) u_imem (
        .addr  (imem_addr),
        .rdata (imem_rdata)
    );

    data_ram u_dmem (
        .clk         (clk),
        .we          (dmem_we),
        .addr        (dmem_addr),
        .wdata       (dmem_wdata),
        .rdata       (dmem_rdata),
        .debug_word0 (debug_mem0)
    );
endmodule
