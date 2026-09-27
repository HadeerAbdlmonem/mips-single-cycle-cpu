//-----------------------------------------------------------------------------
// Module      : alu_control
// Description : Translates the 2-bit ALUOp from the main control unit
//               (and, for R-type instructions, the 6-bit funct field) into
//               the 4-bit ALU operation select code (see alu.v).
//-----------------------------------------------------------------------------
module alu_control (
    input      [1:0] alu_op,
    input      [5:0] funct,
    output reg [3:0] alu_operation
);

    // ALUOp values driven by control.v
    localparam ALUOP_ADD   = 2'b00; // lw/sw: add
    localparam ALUOP_SUB   = 2'b01; // branch: subtract
    localparam ALUOP_RTYPE = 2'b10; // R-type: decode funct
    localparam ALUOP_AND   = 2'b11; // reserved for a future and-immediate opcode

    // R-type funct field encodings
    localparam FUNCT_ADD = 6'h20;
    localparam FUNCT_SUB = 6'h22;
    localparam FUNCT_AND = 6'h24;
    localparam FUNCT_OR  = 6'h25;
    localparam FUNCT_SLT = 6'h2a;
    localparam FUNCT_SLL = 6'h00;
    localparam FUNCT_SRL = 6'h02;
    localparam FUNCT_SRA = 6'h03;

    // 4-bit ALU operation codes (must match alu.v's case statement)
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;
    localparam ALU_SLL = 4'b1000;
    localparam ALU_SRL = 4'b1001;
    localparam ALU_SRA = 4'b1010;

    always @(*) begin
        case (alu_op)
            ALUOP_ADD:   alu_operation = ALU_ADD;
            ALUOP_SUB:   alu_operation = ALU_SUB;
            ALUOP_AND:   alu_operation = ALU_AND;
            ALUOP_RTYPE: begin // R-type: decode funct
                case (funct)
                    FUNCT_ADD: alu_operation = ALU_ADD;
                    FUNCT_AND: alu_operation = ALU_AND;
                    FUNCT_OR:  alu_operation = ALU_OR;
                    FUNCT_SUB: alu_operation = ALU_SUB;
                    FUNCT_SLT: alu_operation = ALU_SLT;
                    FUNCT_SLL: alu_operation = ALU_SLL;
                    FUNCT_SRL: alu_operation = ALU_SRL;
                    FUNCT_SRA: alu_operation = ALU_SRA;
                    default:   alu_operation = ALU_ADD;
                endcase
            end
            default: alu_operation = ALU_ADD;
        endcase
    end

endmodule  // alu_control
