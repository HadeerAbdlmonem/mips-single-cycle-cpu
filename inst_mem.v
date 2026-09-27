//-----------------------------------------------------------------------------
// Module      : inst_mem
// Description : Instruction memory. On rst, clears all 32 words; otherwise
//               fetches the word addressed by pc (word-aligned: pc[31:2]).
//               NOTE: instruction pre-loading is not yet implemented (the
//               "else" branch is a placeholder for filling memory).
//-----------------------------------------------------------------------------
module inst_mem (
    input  wire        rst,
    input        [31:0] pc,
    output reg   [31:0] instruction
);

    reg [31:0] memory[0:31];
    integer i;

    always @(*) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) memory[i] = 0;
        end
        else begin
            // TODO: fill memory with instructions here
        end
        instruction = memory[pc[31:2]];
    end

endmodule  // inst_mem
