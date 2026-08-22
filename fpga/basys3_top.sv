module basys3_top (
    input  logic        clk,
    input  logic        btnC,
    output logic [15:0] led
);
    logic halted;
    logic trap;
    logic [31:0] debug_pc;
    logic [31:0] debug_x10;
    logic [31:0] debug_mem0;

    soc_top #(
        .PROGRAM_HEX("programs/demo.hex")
    ) u_soc (
        .clk        (clk),
        .reset_n    (~btnC),
        .halted     (halted),
        .trap       (trap),
        .debug_pc   (debug_pc),
        .debug_x10  (debug_x10),
        .debug_mem0 (debug_mem0)
    );

    // LED[14:0] shows x10. For the demo, 55 = 0b000000000110111.
    // LED[15] lights when execution halts successfully.
    always_comb begin
        led[14:0] = debug_x10[14:0];
        led[15]   = halted && !trap;
    end
endmodule
