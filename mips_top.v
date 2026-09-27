//-----------------------------------------------------------------------------
// Module      : mips_top
// Description : Single-cycle MIPS CPU datapath. Wires together the program
//               counter, instruction memory, instruction decode, control
//               unit, register file, ALU (+ALU control), data memory, and
//               the muxes/adders needed for sequential execution, taken
//               branches, and jumps.
//
//               Sign-extension of the 16-bit immediate and the branch/jump
//               target address computation are done inline below (each is
//               a single continuous assignment, so a dedicated module
//               would just add indirection without adding clarity).
//-----------------------------------------------------------------------------
module mips_top (
    input clk,
    input rst
);

    // Program counter / instruction fetch
    wire [31:0] pc, pc_plus4, pc_after_branch, pc_next;
    wire [31:0] instruction;

    // Instruction decode fields
    wire [5:0]  opcode, funct;
    wire [4:0]  rs, rt, rd, shamt;
    wire [15:0] immediate;
    wire [25:0] jump_address;

    // Control signals
    wire reg_dst, jump, branch_eq, branch_neq, branch_gt, branch_lt;
    wire mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire [1:0] alu_op;

    // Register file / ALU
    wire [4:0]  write_reg_idx;
    wire [31:0] reg_rs_val, reg_rt_val, reg_write_data;
    wire [31:0] sign_ext_imm, alu_in2, alu_result;
    wire [3:0]  alu_operation;
    wire        bcond, neg;

    // Data memory
    wire [31:0] mem_read_data;

    // Branch/jump target addresses and the taken-branch decision
    wire [31:0] branch_target, jump_target;
    wire        take_branch;

    //-------------------------------------------------------------------
    // Instruction fetch
    //-------------------------------------------------------------------
    program_counter pc_inst (
        .clk   (clk),
        .rst   (rst),
        .pc_in (pc_next),
        .pc_out(pc)
    );

    addr pc_plus4_inst (
        .in (pc),
        .out(pc_plus4)
    );

    inst_mem imem_inst (
        .rst        (rst),
        .pc         (pc),
        .instruction(instruction)
    );

    //-------------------------------------------------------------------
    // Instruction decode
    //-------------------------------------------------------------------
    id_stage id_inst (
        .instruction (instruction),
        .opcode      (opcode),
        .funct       (funct),
        .rs          (rs),
        .rt          (rt),
        .rd          (rd),
        .shamt       (shamt),
        .immediate   (immediate),
        .jump_address(jump_address)
    );

    control ctrl_inst (
        .opcode    (opcode),
        .reg_dst   (reg_dst),
        .jump      (jump),
        .branch_eq (branch_eq),
        .branch_neq(branch_neq),
        .branch_gt (branch_gt),
        .branch_lt (branch_lt),
        .mem_read  (mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op    (alu_op),
        .mem_write (mem_write),
        .alu_src   (alu_src),
        .reg_write (reg_write)
    );

    // RegDst: choose the write-back register index (rt for I-type, rd for R-type)
    mux_2_1 #(.WIDTH(5)) reg_dst_mux (
        .sel(reg_dst),
        .in1(rd),
        .in2(rt),
        .out(write_reg_idx)
    );

    //-------------------------------------------------------------------
    // Register file / ALU
    //-------------------------------------------------------------------
    reg_file regfile_inst (
        .clk            (clk),
        .write_en       (reg_write),
        .read_reg_1     (rs),
        .read_reg_2     (rt),
        .write_reg_index(write_reg_idx),
        .write_data     (reg_write_data),
        .read_data_1    (reg_rs_val),
        .read_data_2    (reg_rt_val)
    );

    // Sign-extend the 16-bit immediate to 32 bits
    assign sign_ext_imm = {{16{immediate[15]}}, immediate};

    // ALUSrc: choose the second ALU operand (register or sign-extended immediate)
    mux_2_1 #(.WIDTH(32)) alu_src_mux (
        .sel(alu_src),
        .in1(sign_ext_imm),
        .in2(reg_rt_val),
        .out(alu_in2)
    );

    alu_control alu_ctrl_inst (
        .alu_op       (alu_op),
        .funct        (funct),
        .alu_operation(alu_operation)
    );

    alu alu_inst (
        .in1          (reg_rs_val),
        .in2          (alu_in2),
        .shamt        (shamt),
        .alu_operation(alu_operation),
        .bcond        (bcond),
        .neg          (neg),
        .alu_result   (alu_result)
    );

    //-------------------------------------------------------------------
    // Data memory
    //-------------------------------------------------------------------
    data_mem dmem_inst (
        .clk       (clk),
        .address   (alu_result),
        .write_data(reg_rt_val),
        .mem_write (mem_write),
        .mem_read  (mem_read),
        .read_data (mem_read_data)
    );

    // MemToReg: choose the value written back to the register file
    mux_2_1 #(.WIDTH(32)) mem_to_reg_mux (
        .sel(mem_to_reg),
        .in1(mem_read_data),
        .in2(alu_result),
        .out(reg_write_data)
    );

    //-------------------------------------------------------------------
    // Next-PC computation: sequential, taken branch, or jump
    //-------------------------------------------------------------------
    // Branch target = (PC + 4) + (sign-extended immediate << 2)
    assign branch_target = pc_plus4 + (sign_ext_imm << 2);

    // Jump target = {top 4 bits of PC+4, 26-bit jump address, 2'b00}
    assign jump_target = {pc_plus4[31:28], jump_address, 2'b00};

    // Combine the branch-type control signals with the ALU's zero/sign
    // flags (computed on rs - rt) into a single taken-branch decision:
    //   beq : rs == rt  -> bcond
    //   bne : rs != rt  -> ~bcond
    //   bgt : rs >  rt  -> result nonzero and positive -> ~neg & ~bcond
    //   blt : rs <  rt  -> result negative              -> neg
    assign take_branch = (branch_eq  &  bcond)
                        | (branch_neq & ~bcond)
                        | (branch_gt  & ~neg & ~bcond)
                        | (branch_lt  &  neg);

    mux_2_1 #(.WIDTH(32)) branch_mux (
        .sel(take_branch),
        .in1(branch_target),
        .in2(pc_plus4),
        .out(pc_after_branch)
    );

    mux_2_1 #(.WIDTH(32)) jump_mux (
        .sel(jump),
        .in1(jump_target),
        .in2(pc_after_branch),
        .out(pc_next)
    );

endmodule
