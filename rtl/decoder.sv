module decoder (
    input  logic [31:0] instr,
    output logic [31:0] imm,
    output logic [3:0]  alu_op,
    output logic        alu_src_imm,
    output logic        reg_write,
    output logic        mem_write,
    output logic [1:0]  wb_sel,
    output logic        branch,
    output logic        branch_ne,
    output logic        jump,
    output logic        halt,
    output logic        illegal
);
    localparam logic [6:0]
        OPCODE_OP     = 7'b0110011,
        OPCODE_OP_IMM = 7'b0010011,
        OPCODE_LOAD   = 7'b0000011,
        OPCODE_STORE  = 7'b0100011,
        OPCODE_BRANCH = 7'b1100011,
        OPCODE_LUI    = 7'b0110111,
        OPCODE_JAL    = 7'b1101111,
        OPCODE_SYSTEM = 7'b1110011;

    localparam logic [3:0]
        ALU_ADD = 4'd0,
        ALU_SUB = 4'd1,
        ALU_AND = 4'd2,
        ALU_OR  = 4'd3,
        ALU_XOR = 4'd4,
        ALU_SLT = 4'd5;

    localparam logic [1:0]
        WB_ALU = 2'd0,
        WB_MEM = 2'd1,
        WB_PC4 = 2'd2,
        WB_IMM = 2'd3;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    always_comb begin
        imm         = 32'd0;
        alu_op      = ALU_ADD;
        alu_src_imm = 1'b0;
        reg_write   = 1'b0;
        mem_write   = 1'b0;
        wb_sel      = WB_ALU;
        branch      = 1'b0;
        branch_ne   = 1'b0;
        jump        = 1'b0;
        halt        = 1'b0;
        illegal     = 1'b0;

        unique case (opcode)
            OPCODE_OP: begin
                reg_write = 1'b1;
                unique case (funct3)
                    3'b000: alu_op = funct7[5] ? ALU_SUB : ALU_ADD;
                    3'b111: alu_op = ALU_AND;
                    3'b110: alu_op = ALU_OR;
                    3'b100: alu_op = ALU_XOR;
                    3'b010: alu_op = ALU_SLT;
                    default: illegal = 1'b1;
                endcase
            end

            OPCODE_OP_IMM: begin
                imm         = {{20{instr[31]}}, instr[31:20]};
                alu_src_imm = 1'b1;
                reg_write   = 1'b1;
                unique case (funct3)
                    3'b000: alu_op = ALU_ADD; // ADDI
                    3'b111: alu_op = ALU_AND; // ANDI
                    3'b110: alu_op = ALU_OR;  // ORI
                    3'b100: alu_op = ALU_XOR; // XORI
                    3'b010: alu_op = ALU_SLT; // SLTI
                    default: illegal = 1'b1;
                endcase
            end

            OPCODE_LOAD: begin
                imm         = {{20{instr[31]}}, instr[31:20]};
                alu_src_imm = 1'b1;
                alu_op      = ALU_ADD;
                reg_write   = 1'b1;
                wb_sel      = WB_MEM;
                if (funct3 != 3'b010)
                    illegal = 1'b1; // only LW
            end

            OPCODE_STORE: begin
                imm         = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                alu_src_imm = 1'b1;
                alu_op      = ALU_ADD;
                mem_write   = 1'b1;
                if (funct3 != 3'b010)
                    illegal = 1'b1; // only SW
            end

            OPCODE_BRANCH: begin
                imm = {{19{instr[31]}}, instr[31], instr[7],
                       instr[30:25], instr[11:8], 1'b0};
                branch = 1'b1;
                unique case (funct3)
                    3'b000: branch_ne = 1'b0; // BEQ
                    3'b001: branch_ne = 1'b1; // BNE
                    default: illegal = 1'b1;
                endcase
            end

            OPCODE_LUI: begin
                imm       = {instr[31:12], 12'd0};
                reg_write = 1'b1;
                wb_sel    = WB_IMM;
            end

            OPCODE_JAL: begin
                imm = {{11{instr[31]}}, instr[31], instr[19:12],
                       instr[20], instr[30:21], 1'b0};
                reg_write = 1'b1;
                wb_sel    = WB_PC4;
                jump      = 1'b1;
            end

            OPCODE_SYSTEM: begin
                if (instr == 32'h0010_0073)
                    halt = 1'b1; // EBREAK
                else
                    illegal = 1'b1;
            end

            default: illegal = 1'b1;
        endcase
    end
endmodule
