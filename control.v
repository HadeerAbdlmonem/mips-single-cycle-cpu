//-----------------------------------------------------------------------------
// Module      : control
// Description : Main control unit. Decodes the instruction opcode into the
//               datapath control signals for each supported instruction
//               class (R-type, lw, sw, beq, bne, j, bgt, blt).
//-----------------------------------------------------------------------------
module control (
    input             [3:0] opcode,
    output reg              reg_dst,
    output reg              jump,
    output reg              branch_eq,
    output reg              branch_neq,
    output reg              branch_gt,
    output reg              branch_lt,
    output reg              mem_read,
    output reg              mem_to_reg,
    output reg        [3:0] alu_op,
    output reg              mem_write,
    output reg              alu_src,
    output reg              reg_write
);

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
        alu_op     = 0;
        mem_write  = 0;
        alu_src    = 0;
        reg_write  = 0;

        case (opcode)
            // R-type instructions (e.g., add, sub, and, or, slt)
            4'b0000: begin
                reg_dst  = 1;      // destination register is rd
                reg_write = 1;     // write the ALU result back to the register file
                alu_op   = 4'b0010; // tell ALU control to look at the funct field
            end
            // Load word (lw)
            4'b0001: begin
                alu_src    = 1; // second ALU input is the immediate/offset
                mem_to_reg = 1; // data to register comes from memory
                reg_write  = 1; // enable writing to the register file
                mem_read   = 1; // enable memory read
                alu_op     = 4'b0000; // ALU performs addition (address calculation)
            end
            // Store word (sw)
            4'b0010: begin
                alu_src   = 1; // second ALU input is the immediate/offset
                mem_write = 1; // enable memory write
                alu_op    = 4'b0000; // ALU performs addition (address calculation)
            end
            // Branch if equal (beq)
            4'b0011: begin
                branch_eq = 1;      // enable branch logic if the zero flag is 1
                alu_op    = 4'b0001; // ALU performs subtraction for comparison
            end
            // Branch if not equal (bne)
            4'b0100: begin
                branch_neq = 1;      // enable branch logic if the zero flag is 0
                alu_op     = 4'b0001; // ALU performs subtraction
            end
            // Jump (j)
            4'b0101: begin
                jump = 1; // force PC to jump to the target address
            end
            // Branch if greater than (bgt)
            4'b0110: begin
                branch_gt = 1;
                alu_op    = 4'b0001; // ALU performs subtraction
            end
            // Branch if less than (blt)
            4'b0111: begin
                branch_lt = 1;
                alu_op    = 4'b0001; // ALU performs subtraction
            end
            default: begin
                // Unrecognized opcode: keep all control signals at their
                // default (inactive) values set above.
            end
        endcase
    end

endmodule
