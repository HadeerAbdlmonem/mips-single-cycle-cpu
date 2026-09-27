//-----------------------------------------------------------------------------
// Module      : alu_control
// Description : Translates the 2-bit ALUOp from the main control unit
//               (and, for R-type instructions, the 6-bit funct field) into
//               the 4-bit ALU operation select code.
//-----------------------------------------------------------------------------
module alu_control (
    input      [1:0] alu_op,
    input      [5:0] funct,
    output reg [3:0] alu_operation
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_operation = 4'b0010; // lw/sw: add
            2'b01: alu_operation = 4'b0110; // branch: subtract
            2'b11: alu_operation = 4'b0000; // and
            2'b10: begin                    // R-type: decode funct
                case (funct)
                    6'h20: alu_operation = 4'b0010; // add
                    6'h24: alu_operation = 4'b0000; // and
                    6'h25: alu_operation = 4'b0001; // or
                    6'h22: alu_operation = 4'b0110; // sub
                    6'h2a: alu_operation = 4'b0111; // slt
                    6'h00: alu_operation = 4'b1000; // sll
                    6'h02: alu_operation = 4'b1001; // srl
                    6'h03: alu_operation = 4'b1010; // sra
                    default: alu_operation = 4'b0010;
                endcase
            end
            default: alu_operation = 4'b0010;
        endcase
    end

endmodule  // alu_control
