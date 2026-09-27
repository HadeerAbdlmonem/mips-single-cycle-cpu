//-----------------------------------------------------------------------------
// Module      : mux_2_1
// Description : Generic 2-to-1 multiplexer, WIDTH bits wide (default 32).
//               sel selects in1 when high, in2 when low.
//-----------------------------------------------------------------------------
module mux_2_1 #(
    parameter WIDTH = 32
) (
    input  wire              sel,
    input  wire [WIDTH-1:0]  in1,
    input  wire [WIDTH-1:0]  in2,
    output reg  [WIDTH-1:0]  out
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
