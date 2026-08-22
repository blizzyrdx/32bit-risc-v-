module rv32i_core (
    input  logic        clk,
    input  logic        reset_n,

    output logic [31:0] imem_addr,
    input  logic [31:0] imem_rdata,

    output logic        dmem_we,
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    input  logic [31:0] dmem_rdata,

    output logic        halted,
    output logic        trap,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_x10
);
    localparam logic [1:0]
        WB_ALU = 2'd0,
        WB_MEM = 2'd1,
        WB_PC4 = 2'd2,
        WB_IMM = 2'd3;

    logic [31:0] pc;
    logic [31:0] pc_next;
    logic [31:0] imm;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] alu_b;
    logic [31:0] alu_y;
    logic [31:0] wb_data;
    logic        alu_zero;
    logic        take_branch;

    logic [3:0]  alu_op;
    logic        alu_src_imm;
    logic        reg_write;
    logic        mem_write;
    logic [1:0]  wb_sel;
    logic        branch;
    logic        branch_ne;
    logic        jump;
    logic        halt_dec;
    logic        illegal_dec;

    wire [4:0] rs1 = imem_rdata[19:15];
    wire [4:0] rs2 = imem_rdata[24:20];
    wire [4:0] rd  = imem_rdata[11:7];

    decoder u_decoder (
        .instr       (imem_rdata),
        .imm         (imm),
        .alu_op      (alu_op),
        .alu_src_imm (alu_src_imm),
        .reg_write   (reg_write),
        .mem_write   (mem_write),
        .wb_sel      (wb_sel),
        .branch      (branch),
        .branch_ne   (branch_ne),
        .jump        (jump),
        .halt        (halt_dec),
        .illegal     (illegal_dec)
    );

    regfile u_regfile (
        .clk         (clk),
        .reset_n     (reset_n),
        .write_en    (reg_write && !halted && !halt_dec && !illegal_dec),
        .rs1         (rs1),
        .rs2         (rs2),
        .rd          (rd),
        .write_data  (wb_data),
        .read_data1  (rs1_data),
        .read_data2  (rs2_data),
        .debug_x10   (debug_x10)
    );

    assign alu_b = alu_src_imm ? imm : rs2_data;

    alu u_alu (
        .a    (rs1_data),
        .b    (alu_b),
        .op   (alu_op),
        .y    (alu_y),
        .zero (alu_zero)
    );

    always_comb begin
        unique case (wb_sel)
            WB_ALU: wb_data = alu_y;
            WB_MEM: wb_data = dmem_rdata;
            WB_PC4: wb_data = pc + 32'd4;
            WB_IMM: wb_data = imm;
            default: wb_data = 32'd0;
        endcase
    end

    assign take_branch = branch && (branch_ne ? (rs1_data != rs2_data)
                                               : (rs1_data == rs2_data));

    always_comb begin
        pc_next = pc + 32'd4;
        if (take_branch)
            pc_next = pc + imm;
        if (jump)
            pc_next = pc + imm;
        if (halt_dec || illegal_dec)
            pc_next = pc;
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc     <= 32'd0;
            halted <= 1'b0;
            trap   <= 1'b0;
        end else if (!halted) begin
            if (illegal_dec) begin
                halted <= 1'b1;
                trap   <= 1'b1;
            end else if (halt_dec) begin
                halted <= 1'b1;
            end else begin
                pc <= pc_next;
            end
        end
    end

    assign imem_addr  = pc;
    assign dmem_addr  = alu_y;
    assign dmem_wdata = rs2_data;
    assign dmem_we    = mem_write && !halted && !halt_dec && !illegal_dec;
    assign debug_pc   = pc;
endmodule
