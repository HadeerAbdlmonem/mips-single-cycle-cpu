//-----------------------------------------------------------------------------
// Module      : mux_2_1
// Description : 2-to-1 32-bit multiplexer. sel selects in1 when high,
//               in2 when low.
//-----------------------------------------------------------------------------
module mux_2_1 (
    input  wire         sel,
    input  wire [31:0]  in1,
    input  wire [31:0]  in2,
    output reg  [31:0]  out
);

    always @(*) begin
        if (sel) begin
            out = in1;
        end
        else begin
            out = in2;
        end
    end

endmodule  // mux_2_1
