//-----------------------------------------------------------------------------
// Module      : alu
// Description : MIPS ALU. Supports AND, OR, ADD, SUB, SLT, NOR, and
//               logical/arithmetic shifts by shamt.
//               bcond is asserted when the result is zero (used for
//               branch-equal/not-equal). neg is the result's sign bit
//               (used for branch-greater-than/branch-less-than, which a
//               zero flag alone cannot distinguish).
//-----------------------------------------------------------------------------
module alu (
    input  wire [31:0] in1,
    input  wire [31:0] in2,
    input  wire [4:0]  shamt,
    input  wire [3:0]  alu_operation,
    output wire         bcond,
    output wire         neg,
    output reg  [31:0] alu_result
);

    always @(*) begin
        case (alu_operation)
            4'b0000: alu_result = in1 & in2;
            4'b0001: alu_result = in1 | in2;
            4'b0010: alu_result = in1 + in2;
            4'b0110: alu_result = in1 - in2;
            4'b0111: alu_result = (in1 < in2);
            4'b1100: alu_result = ~(in1 | in2);
            4'b1000: alu_result = in2 << shamt;
            4'b1001: alu_result = in2 >> shamt;
            4'b1010: alu_result = $signed(in2) >>> shamt;
            default: alu_result = 0;
        endcase
    end

    assign bcond = (alu_result == 32'b0) ? 1 : 0;
    assign neg   = alu_result[31];

endmodule  // alu
