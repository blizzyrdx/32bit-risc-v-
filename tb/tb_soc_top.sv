`timescale 1ns/1ps

module tb_soc_top;
    logic clk = 1'b0;
    logic reset_n = 1'b0;
    logic halted;
    logic trap;
    logic [31:0] debug_pc;
    logic [31:0] debug_x10;
    logic [31:0] debug_mem0;

    integer cycles;

    always #5 clk = ~clk;

    soc_top #(
        .PROGRAM_HEX("programs/demo.hex")
    ) dut (
        .clk        (clk),
        .reset_n    (reset_n),
        .halted     (halted),
        .trap       (trap),
        .debug_pc   (debug_pc),
        .debug_x10  (debug_x10),
        .debug_mem0 (debug_mem0)
    );

    initial begin
        $dumpfile("build/rv32i_chip.vcd");
        $dumpvars(0, tb_soc_top);

        repeat (3) @(posedge clk);
        reset_n <= 1'b1;

        cycles = 0;
        while (!halted && cycles < 200) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        // Let final nonblocking assignments settle.
        #1;

        if (!halted) begin
            $error("FAIL: CPU did not halt within 200 cycles");
            $finish_and_return(1);
        end

        if (trap) begin
            $error("FAIL: CPU trapped on an illegal instruction at PC=0x%08x", debug_pc);
            $finish_and_return(1);
        end

        if (debug_x10 !== 32'd55) begin
            $error("FAIL: x10 expected 55, got %0d", debug_x10);
            $finish_and_return(1);
        end

        if (debug_mem0 !== 32'd55) begin
            $error("FAIL: memory[0] expected 55, got %0d", debug_mem0);
            $finish_and_return(1);
        end

        $display("PASS: CPU halted after %0d cycles", cycles);
        $display("PASS: x10 = %0d", debug_x10);
        $display("PASS: memory[0] = %0d", debug_mem0);
        $finish;
    end
endmodule
