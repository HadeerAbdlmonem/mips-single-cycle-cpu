//-----------------------------------------------------------------------------
// Testbench   : mips_tb
// Description : Preloads a small hand-assembled test program directly into
//               mips_top's instruction memory (and a couple of starting
//               register values into its register file) via hierarchical
//               references, runs it, and self-checks the resulting
//               register/memory state against the expected values.
//
//               Program exercised (word addresses in comments):
//                 0  add  $4, $1, $2        ; $4 = 10 + 20 = 30
//                 1  sw   $4, 0($3)         ; mem[100] = 30
//                 2  lw   $5, 0($3)         ; $5 = mem[100] = 30
//                 3  beq  $1, $1, 2         ; always taken -> skip to word 6
//                 4  add  $6, $1, $1        ; (skipped)
//                 5  add  $6, $1, $1        ; (skipped)
//                 6  add  $7, $1, $2        ; $7 = 10 + 20 = 30 (confirms beq worked)
//                 7  j    9                 ; always taken -> skip to word 9
//                 8  add  $8, $1, $1        ; (skipped)
//                 9  add  $9, $2, $2        ; $9 = 20 + 20 = 40 (confirms j worked)
//                 10 bne  $1, $1, 5         ; never taken (rs == rt)
//                 11 add  $10, $3, $3       ; $10 = 100 + 100 = 200 (confirms non-taken branch)
//-----------------------------------------------------------------------------
module mips_tb ();

    reg clk, rst;
    integer error_count = 0;

    mips_top dut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever begin
            #1;
            clk = ~clk;
        end
    end

    // R-type / I-type / J-type instruction-word builders, so the program
    // below is written in terms of fields instead of hand-packed bits.
    function [31:0] r_type(input [5:0] opcode, input [4:0] rs, rt, rd, shamt, input [5:0] funct);
        r_type = {opcode, rs, rt, rd, shamt, funct};
    endfunction

    function [31:0] i_type(input [5:0] opcode, input [4:0] rs, rt, input [15:0] imm);
        i_type = {opcode, rs, rt, imm};
    endfunction

    function [31:0] j_type(input [5:0] opcode, input [25:0] jump_addr);
        j_type = {opcode, jump_addr};
    endfunction

    // Opcodes / functs (must match control.v / alu_control.v)
    localparam OPCODE_RTYPE = 6'b000000;
    localparam OPCODE_LW    = 6'b100011;
    localparam OPCODE_SW    = 6'b101011;
    localparam OPCODE_BEQ   = 6'b000100;
    localparam OPCODE_BNE   = 6'b000101;
    localparam OPCODE_J     = 6'b000010;
    localparam FUNCT_ADD    = 6'h20;

    initial begin
        // Hold reset for a cycle: clears inst_mem and parks the PC at 0.
        rst = 1;
        @(negedge clk);
        rst = 0;

        // Preload starting register values (reg_file has no reset for
        // registers 1-31, so this must happen before the first fetch
        // reads them). $6/$8 are sentinels that must stay 0 -- if the
        // branch/jump skip logic is broken, the "skipped" instructions
        // below would overwrite them.
        dut.regfile_inst.registers[1] = 32'd10;
        dut.regfile_inst.registers[2] = 32'd20;
        dut.regfile_inst.registers[3] = 32'd100; // sw/lw base address
        dut.regfile_inst.registers[6] = 32'd0;   // sentinel: must stay 0 (beq skip)
        dut.regfile_inst.registers[8] = 32'd0;   // sentinel: must stay 0 (j skip)

        // Preload the test program (see the file header for the listing).
        dut.imem_inst.memory[0]  = r_type(OPCODE_RTYPE, 5'd1, 5'd2, 5'd4, 5'd0, FUNCT_ADD);
        dut.imem_inst.memory[1]  = i_type(OPCODE_SW,    5'd3, 5'd4, 16'd0);
        dut.imem_inst.memory[2]  = i_type(OPCODE_LW,    5'd3, 5'd5, 16'd0);
        dut.imem_inst.memory[3]  = i_type(OPCODE_BEQ,   5'd1, 5'd1, 16'd2);
        dut.imem_inst.memory[4]  = r_type(OPCODE_RTYPE, 5'd1, 5'd1, 5'd6, 5'd0, FUNCT_ADD);
        dut.imem_inst.memory[5]  = r_type(OPCODE_RTYPE, 5'd1, 5'd1, 5'd6, 5'd0, FUNCT_ADD);
        dut.imem_inst.memory[6]  = r_type(OPCODE_RTYPE, 5'd1, 5'd2, 5'd7, 5'd0, FUNCT_ADD);
        dut.imem_inst.memory[7]  = j_type(OPCODE_J,     26'd9);
        dut.imem_inst.memory[8]  = r_type(OPCODE_RTYPE, 5'd1, 5'd1, 5'd8, 5'd0, FUNCT_ADD);
        dut.imem_inst.memory[9]  = r_type(OPCODE_RTYPE, 5'd2, 5'd2, 5'd9, 5'd0, FUNCT_ADD);
        dut.imem_inst.memory[10] = i_type(OPCODE_BNE,   5'd1, 5'd1, 16'd5);
        dut.imem_inst.memory[11] = r_type(OPCODE_RTYPE, 5'd3, 5'd3, 5'd10, 5'd0, FUNCT_ADD);

        // 12 instructions are dynamically executed (see the header listing);
        // run a couple of extra cycles of margin before checking.
        repeat (14) @(negedge clk);

        check(dut.regfile_inst.registers[4],  32'd30,  "$4  (add)");
        check(dut.dmem_inst.memory[100],      32'd30,  "mem[100] (sw)");
        check(dut.regfile_inst.registers[5],  32'd30,  "$5  (lw)");
        check(dut.regfile_inst.registers[6],  32'd0,   "$6  (beq must skip)");
        check(dut.regfile_inst.registers[7],  32'd30,  "$7  (after taken beq)");
        check(dut.regfile_inst.registers[8],  32'd0,   "$8  (j must skip)");
        check(dut.regfile_inst.registers[9],  32'd40,  "$9  (after taken j)");
        check(dut.regfile_inst.registers[10], 32'd200, "$10 (after non-taken bne)");

        $display("\nmips_tb: error_count = %0d\n", error_count);
        $stop();
    end

    task check(input [31:0] actual, input [31:0] expected, input [40*8-1:0] label);
        if (actual !== expected) begin
            error_count = error_count + 1;
            $display("ERROR: %0s -> actual=%0d expected=%0d", label, actual, expected);
        end
        else begin
            $display("PASS : %0s -> %0d", label, actual);
        end
    endtask

endmodule
