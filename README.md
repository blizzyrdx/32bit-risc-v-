# RV32I Starter Chip Project

A small, modular **32-bit RISC-V-style CPU** written in SystemVerilog. It is intentionally compact enough to understand end-to-end while still exposing the same ideas used in larger ASIC/FPGA projects: RTL design, instruction decode, register files, ALUs, branches, memories, testbenches, synthesis, timing, and FPGA bring-up.

## What it does

The included program computes:

`10 + 9 + ... + 1 = 55`

It places **55 in register x10**, stores **55 at data-memory address 0**, and executes `EBREAK`. The testbench fails automatically if either result is wrong.

## Implemented instruction subset

- R-type: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`
- I-type: `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`
- Memory: `LW`, `SW`
- Branch: `BEQ`, `BNE`
- Control: `JAL`
- Upper immediate: `LUI`
- Debug halt: `EBREAK`

This is a learning core, **not a complete RV32I-compliant processor yet**.

## Project layout

```text
rv32i_chip_project/
├── rtl/
│   ├── alu.sv
│   ├── decoder.sv
│   ├── regfile.sv
│   ├── rv32i_core.sv
│   ├── instruction_rom.sv
│   ├── data_ram.sv
│   └── soc_top.sv
├── tb/
│   └── tb_soc_top.sv
├── programs/
│   ├── demo.S
│   └── demo.hex
├── scripts/
│   ├── encode_demo.py
│   └── synth_yosys.ys
├── fpga/
│   ├── basys3_top.sv
│   └── Basys3.xdc
└── Makefile
```

## Run the simulation

Install Icarus Verilog and GTKWave, then from the project root:

```bash
make sim
```

Expected result:

```text
PASS: CPU halted ...
PASS: x10 = 55
PASS: memory[0] = 55
```

Open the waveform:

```bash
make wave
```

Useful signals to inspect:

- `debug_pc`
- `debug_x10`
- `debug_mem0`
- `dut.u_core.imem_rdata`
- `dut.u_core.rs1_data`
- `dut.u_core.rs2_data`
- `dut.u_core.alu_y`
- `dut.u_core.dmem_we`

## Synthesize with Yosys

```bash
make synth
```

That synthesizes the CPU core and writes `build/rv32i_core.json`.

## Run it on a Basys 3 in Vivado

1. Create a new **RTL Project** for the Basys 3 / Artix-7.
2. Add every `.sv` file in `rtl/`.
3. Add `fpga/basys3_top.sv`.
4. Add `fpga/Basys3.xdc` as a constraints file.
5. Add `programs/demo.hex` as a memory/init source if Vivado does not locate it automatically.
6. Set `basys3_top` as the top module.
7. Run Synthesis → Implementation → Generate Bitstream.
8. Program the FPGA through Hardware Manager.
9. Press the center button to reset/restart the processor.

When the program finishes, **LD15 lights to show HALT**, while **LD0-LD14 display x10**. The value 55 should appear as binary `000000000110111` on the lower LEDs.

## Why this is useful for chip-design internships

This project gives you a base for four different directions:

### RTL / ASIC design
Add more RV32I instructions, a CSR block, interrupts, a multiplier/divider, and eventually a pipeline.

### Computer architecture
Turn the core into a 5-stage pipeline, then implement forwarding, hazard detection, branch prediction, and caches.

### Verification
Replace the simple directed testbench with SystemVerilog assertions, randomized instruction streams, functional coverage, and eventually UVM.

### Physical design
Synthesize the core, run static timing analysis, then take it through OpenROAD for floorplanning, placement, clock-tree synthesis, routing, and GDSII generation.

## Recommended upgrades

1. Implement the complete base RV32I ISA.
2. Add a 5-stage `IF/ID/EX/MEM/WB` pipeline.
3. Add forwarding and load-use hazard detection.
4. Add SystemVerilog Assertions (SVA).
5. Create a Python reference-model checker.
6. Add instruction and data caches.
7. Add UART output on the Basys 3.
8. Run synthesis and collect area/timing reports.
9. Run OpenROAD and generate a physical layout.
10. Add CI so every GitHub push automatically runs the testbench.

That progression turns this from a starter CPU into a legitimate **computer architecture + RTL + verification + ASIC-flow portfolio project**.
