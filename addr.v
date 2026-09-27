//-----------------------------------------------------------------------------
// Module      : addr
// Description : Computes the sequential next-PC value (pc + 4).
//-----------------------------------------------------------------------------
module addr #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] in,
    output reg  [WIDTH-1:0] out
);

    always @(*) begin
        out = in + 4;
    end

endmodule
