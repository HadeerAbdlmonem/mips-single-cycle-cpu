//-----------------------------------------------------------------------------
// Module      : control
// Description : Main control unit. Decodes the 6-bit instruction opcode
//               (instruction[31:26], matching id_stage's opcode output)
//               into the datapath control signals for each supported
//               instruction class (R-type, lw, sw, beq, bne, j, bgt, blt).
//
//               alu_op is the 2-bit ALUOp fed to alu_control, NOT the final
//               4-bit ALU operation code:
//                 2'b00 : lw/sw            -> alu_control drives ADD
//                 2'b01 : beq/bne/bgt/blt  -> alu_control drives SUBTRACT
//                 2'b10 : R-type           -> alu_control decodes funct
//
//               bgt/blt are not standard MIPS opcodes (real MIPS only
//               branches on zero/sign against a single register); they are
//               kept here as a custom extension using two unused opcode
//               encodings, and are resolved in the top level using the
//               ALU's neg/bcond flags.
//-----------------------------------------------------------------------------
module control (
    input             [5:0] opcode,
    output reg              reg_dst,
    output reg              jump,
    output reg              branch_eq,
    output reg              branch_neq,
    output reg              branch_gt,
    output reg              branch_lt,
    output reg              mem_read,
    output reg              mem_to_reg,
    output reg        [1:0] alu_op,
    output reg              mem_write,
    output reg              alu_src,
    output reg              reg_write
);

    // Standard MIPS opcodes
    localparam OPCODE_RTYPE = 6'b000000;
    localparam OPCODE_LW    = 6'b100011; // 0x23
    localparam OPCODE_SW    = 6'b101011; // 0x2B
    localparam OPCODE_BEQ   = 6'b000100; // 0x04
    localparam OPCODE_BNE   = 6'b000101; // 0x05
    localparam OPCODE_J     = 6'b000010; // 0x02
    // Custom (non-standard MIPS) opcodes, using unused encodings
    localparam OPCODE_BGT   = 6'b011110;
    localparam OPCODE_BLT   = 6'b011111;

    // ALUOp values fed to alu_control (see file header)
    localparam ALUOP_ADD   = 2'b00;
    localparam ALUOP_SUB   = 2'b01;
    localparam ALUOP_RTYPE = 2'b10;

    always @(*) begin
        // Default values every cycle: prevents inferred latches and resets
        // every control signal before the case below sets the ones needed.
        reg_dst    = 0;
        jump       = 0;
        branch_eq  = 0;
        branch_neq = 0;
        branch_gt  = 0;
        branch_lt  = 0;
        mem_read   = 0;
        mem_to_reg = 0;
        alu_op     = ALUOP_ADD;
        mem_write  = 0;
        alu_src    = 0;
        reg_write  = 0;

        case (opcode)
            // R-type instructions (e.g., add, sub, and, or, slt, sll, srl, sra)
            OPCODE_RTYPE: begin
                reg_dst   = 1;         // destination register is rd
                reg_write = 1;         // write the ALU result back to the register file
                alu_op    = ALUOP_RTYPE; // tell ALU control to look at the funct field
            end
            // Load word (lw)
            OPCODE_LW: begin
                alu_src    = 1; // second ALU input is the immediate/offset
                mem_to_reg = 1; // data to register comes from memory
                reg_write  = 1; // enable writing to the register file
                mem_read   = 1; // enable memory read
                alu_op     = ALUOP_ADD; // ALU performs addition (address calculation)
            end
            // Store word (sw)
            OPCODE_SW: begin
                alu_src   = 1; // second ALU input is the immediate/offset
                mem_write = 1; // enable memory write
                alu_op    = ALUOP_ADD; // ALU performs addition (address calculation)
            end
            // Branch if equal (beq)
            OPCODE_BEQ: begin
                branch_eq = 1;        // enable branch logic if the zero flag is 1
                alu_op    = ALUOP_SUB; // ALU performs subtraction for comparison
            end
            // Branch if not equal (bne)
            OPCODE_BNE: begin
                branch_neq = 1;        // enable branch logic if the zero flag is 0
                alu_op     = ALUOP_SUB; // ALU performs subtraction
            end
            // Jump (j)
            OPCODE_J: begin
                jump = 1; // force PC to jump to the target address
            end
            // Branch if greater than (bgt) -- custom, see file header
            OPCODE_BGT: begin
                branch_gt = 1;
                alu_op    = ALUOP_SUB; // ALU performs subtraction
            end
            // Branch if less than (blt) -- custom, see file header
            OPCODE_BLT: begin
                branch_lt = 1;
                alu_op    = ALUOP_SUB; // ALU performs subtraction
            end
            default: begin
                // Unrecognized opcode: keep all control signals at their
                // default (inactive) values set above.
            end
        endcase
    end

endmodule
