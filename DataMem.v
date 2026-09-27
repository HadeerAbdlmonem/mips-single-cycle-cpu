//-----------------------------------------------------------------------------
// Module      : data_mem
// Description : Data memory. Synchronous write on mem_write; combinational
//               read on mem_read (reads 0 when mem_read is low).
//-----------------------------------------------------------------------------
module data_mem (
    input               clk,
    input  wire [31:0]  address,
    input  wire [31:0]  write_data,
    input  wire         mem_write,
    input  wire         mem_read,
    output      [31:0]  read_data
);

    reg [31:0] memory[0:256];

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write) memory[address] <= write_data;
    end

    // Combinational read
    assign read_data = (mem_read) ? memory[address] : 0;

endmodule  // data_mem
