# 🖥️ MIPS — Single-Cycle CPU

![Verilog](https://img.shields.io/badge/Verilog-HDL-1f6feb?style=flat-square)
![ISA](https://img.shields.io/badge/ISA-MIPS-9c27b0?style=flat-square)
![Simulator](https://img.shields.io/badge/Simulator-QuestaSim-red?style=flat-square)

A structural, single-cycle **MIPS CPU** in Verilog: a classic 5-stage-style
datapath (fetch → decode → execute → memory → write-back) collapsed into one
clock cycle per instruction, built from small, independently reusable modules.

## 🏗️ Architecture

`mips_top.v` wires the pieces below into the full datapath:

| Module | File | Description |
|---|---|---|
| ⏱️ `program_counter` | [`program_counter.v`](./program_counter.v) | PC register with async reset |
| ➕ `addr` | [`addr.v`](./addr.v) | Computes `pc + 4` |
| 📖 `inst_mem` | [`inst_mem.v`](./inst_mem.v) | Word-addressed instruction memory (32 words) |
| 🧩 `id_stage` | [`ID_Stage.v`](./ID_Stage.v) | Splits the instruction into opcode/rs/rt/rd/shamt/funct/immediate/jump-address |
| 🚦 `control` | [`control.v`](./control.v) | Decodes the 6-bit opcode into all datapath control signals |
| 📇 `reg_file` | [`Registers.v`](./Registers.v) | 32×32-bit register file, `$0` hardwired to zero |
| 🎛️ `alu_control` | [`ALUControl.v`](./ALUControl.v) | Decodes `ALUOp` + `funct` into the ALU's operation select |
| 🧮 `alu` | [`ALU.v`](./ALU.v) | AND, OR, ADD, SUB, SLT, NOR, shifts; exposes `bcond` (zero) and `neg` (sign) flags |
| 💾 `data_mem` | [`DataMem.v`](./DataMem.v) | Synchronous-write / combinational-read data memory |
| 🔀 `mux_2_1` | [`Mux_2_1.v`](./Mux_2_1.v) | Generic, width-parameterized 2-to-1 mux (used 5×: RegDst, ALUSrc, MemToReg, branch, jump) |

Sign-extension of the immediate and the branch/jump target address math are
done inline in `mips_top.v` as single continuous assignments.

## ⚙️ Supported Instructions

| Opcode (`instruction[31:26]`) | Instruction | Notes |
|:---:|---|---|
| `000000` | R-type: `add sub and or slt sll srl sra` | Selected via the 6-bit `funct` field |
| `100011` | `lw` | Standard MIPS encoding |
| `101011` | `sw` | Standard MIPS encoding |
| `000100` | `beq` | Standard MIPS encoding |
| `000101` | `bne` | Standard MIPS encoding |
| `000010` | `j` | Standard MIPS encoding |
| `011110` | `bgt` (custom) | Not a real MIPS opcode — real MIPS has no two-register "greater than" branch. Resolved using the ALU's `neg`/`bcond` flags. |
| `011111` | `blt` (custom) | Same as above. |

## ✅ Verification

[`mips_tb.v`](./mips_tb.v) hand-assembles a small self-checking test program
directly into `inst_mem` (via `r_type`/`i_type`/`j_type` helper functions, so
the program is written in terms of fields rather than raw bits) and preloads
a few starting register values. It exercises:

- an R-type `add`
- `sw` followed by `lw` round-tripping through data memory
- a **taken** `beq`, with sentinel registers that must *not* change if a
  skipped instruction wrongly executes
- `j`, with the same skip-verification technique
- a **not-taken** `bne`, confirming normal sequential fall-through

Each check prints `PASS`/`ERROR` and the run finishes with a total
`error_count`.

## ▶️ Running

```bash
vsim -do run.do
```

## ⚠️ Known Limitations

- `inst_mem` has no general-purpose program loader (e.g. `$readmemh`) — test
  programs are preloaded by a testbench via hierarchical references, as
  `mips_tb.v` does
- No exception/interrupt handling, no delay slots, no pipelining (by design —
  this is a single-cycle implementation)
