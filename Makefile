RTL := rtl/alu.sv rtl/regfile.sv rtl/decoder.sv rtl/rv32i_core.sv rtl/instruction_rom.sv rtl/data_ram.sv rtl/soc_top.sv
TB  := tb/tb_soc_top.sv

.PHONY: all sim wave synth encode clean

all: sim

build:
	mkdir -p build

encode:
	python3 scripts/encode_demo.py

sim: build encode
	iverilog -g2012 -Wall -s tb_soc_top -o build/rv32i_sim $(RTL) $(TB)
	vvp build/rv32i_sim

wave: sim
	gtkwave build/rv32i_chip.vcd

synth: build
	yosys -s scripts/synth_yosys.ys

clean:
	rm -rf build
