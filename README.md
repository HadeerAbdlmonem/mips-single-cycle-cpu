# 🖥️ MIPS — Single-Cycle CPU Datapath Components

![Verilog](https://img.shields.io/badge/Verilog-HDL-1f6feb?style=flat-square)
![ISA](https://img.shields.io/badge/ISA-MIPS-9c27b0?style=flat-square)
![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow?style=flat-square)

Structural Verilog building blocks for a classic **single-cycle MIPS CPU** datapath.
Each module below is standalone and unit-testable; they are not yet wired together
into a top-level CPU.

## 📦 Modules

| Module | File | Description |
|---|---|---|
| 🧮 `alu` | [`ALU.v`](./ALU.v) | AND, OR, ADD, SUB, SLT, NOR, and shift-left/right/arithmetic-right by `shamt` |
| 🎛️ `alu_control` | [`ALUControl.v`](./ALUControl.v) | Decodes `ALUOp` + `funct` into the 4-bit ALU operation select |
| 🚦 `control` | [`control.v`](./control.v) | Main control unit — decodes the opcode into all datapath control signals |
| 💾 `data_mem` | [`DataMem.v`](./DataMem.v) | Synchronous-write / combinational-read data memory |
| 🧩 `id_stage` | [`ID_Stage.v`](./ID_Stage.v) | Splits a 32-bit instruction into opcode/rs/rt/rd/shamt/funct/immediate/jump-address fields |
| 📖 `inst_mem` | [`inst_mem.v`](./inst_mem.v) | Word-addressed instruction memory (32 words) |
| 🔀 `mux_2_1` | [`Mux_2_1.v`](./Mux_2_1.v) | Generic 32-bit 2-to-1 multiplexer |
| 📇 `reg_file` | [`Registers.v`](./Registers.v) | 32×32-bit register file, register 0 hardwired to zero |
| ➕ `addr` | [`addr.v`](./addr.v) | Computes the sequential next-PC value (`pc + 4`) |
| ⏱️ `program_counter` | [`program_counter.v`](./program_counter.v) | PC register with async reset |

## ⚠️ Known Limitations

- No top-level module wiring the pieces into a full datapath yet
- `inst_mem` has no instruction pre-load — the memory is cleared on reset and
  otherwise empty (see the `TODO` in the source)
- No testbenches included yet for this folder

## 🗺️ Roadmap

- [ ] Wire the modules into a `mips_top` single-cycle datapath
- [ ] Add instruction pre-loading (e.g. `$readmemh`)
- [ ] Add a self-checking testbench running a small test program
