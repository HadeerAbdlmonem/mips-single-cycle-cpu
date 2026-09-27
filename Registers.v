//-----------------------------------------------------------------------------
// Module      : reg_file
// Description : 32x32-bit MIPS register file. Synchronous write on
//               write_en; two combinational read ports. Register 0 is
//               hardwired to zero.
//-----------------------------------------------------------------------------
module reg_file (
    input               clk,
    input               write_en,
    input        [4:0]  read_reg_1,
    input        [4:0]  read_reg_2,
    input        [4:0]  write_reg_index,
    input        [31:0] write_data,
    output       [31:0] read_data_1,
    output       [31:0] read_data_2
);

    reg [31:0] registers[0:31];

    // Synchronous write; register 0 is always forced back to zero.
    always @(posedge clk) begin
        if (write_en) registers[write_reg_index] <= write_data;
        registers[0] <= 0;
    end

    // Combinational read
    assign read_data_1 = registers[read_reg_1];
    assign read_data_2 = registers[read_reg_2];

endmodule  // reg_file
