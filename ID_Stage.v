//-----------------------------------------------------------------------------
// Module      : id_stage
// Description : Instruction decode: splits a 32-bit MIPS instruction word
//               into its opcode, register, immediate and jump-address
//               fields.
//-----------------------------------------------------------------------------
module id_stage (
    input  wire [31:0] instruction,
    output wire [5:0]  opcode,
    output wire [5:0]  funct,
    output wire [4:0]  rs,
    output wire [4:0]  rt,
    output wire [4:0]  rd,
    output wire [4:0]  shamt,
    output wire [15:0] immediate,
    output wire [25:0] jump_address
);

    assign opcode       = instruction[31:26];
    assign rs           = instruction[25:21];
    assign rt           = instruction[20:16];
    assign rd           = instruction[15:11];
    assign shamt        = instruction[10:6];
    assign funct        = instruction[5:0];
    assign immediate    = instruction[15:0];
    assign jump_address = instruction[25:0];

endmodule  // id_stage
