
help:
	$(info make help           - show this message)
	$(info make clean          - delete synth and simulation folders)
	$(info make sim            - the same as sim_gui)
	$(info make synth          - clean, create the board project and run the synthesis (for default board))
	$(info make open           - the same as synth_gui)
	$(info make load           - the same as synth_load)
	$(info make sim_cmd        - run simulation in Modelsim (console mode))
	$(info make sim_gui        - run simulation in Modelsim (gui mode))
	$(info make synth_create   - create the board project)
	$(info make synth_build_q  - build the board project with quartus)
	$(info make synth_gui_q    - open the board project with quartus)
	$(info make synth_load_q   - program the default FPGA board with quartus)
	$(info make board_all      - run synthesis for all the supported boards)
	$(info make prog_comp_win  - compile program on windows and copy program.hex to program_file)
	$(info make prog_comp_lin  - compile program on linux and copy program.hex to program_file)
	$(info Open and read the Makefile for details)
	@true

PWD     := $(shell pwd)
BRD_DIR  = $(PWD)/board
RUN_DIR  = $(PWD)/run
RTL_DIR  = $(PWD)/rtl
TB_DIR   = $(PWD)/tb

BOARDS_SUPPORTED ?= de10_lite
BOARD            ?= de10_lite

########################################################
# common make targets

show_pwd:
	PWD

clean: \
	sim_clean \
	board_clean \
	log_clean \
	prog_clean

sim_all: \
	sim_cmd 

sim: sim_gui

create: synth_create

synth_q: \
	synth_clean \
	synth_create \
	synth_build_q

load_q: synth_load_q

open_q: synth_gui_q

########################################################
# simulation - Modelsim

VSIM_DIR = $(PWD)/sim_modelsim

VLIB_BIN = cd $(VSIM_DIR) && vlib
VLOG_BIN = cd $(VSIM_DIR) && vlog
VSIM_BIN = cd $(VSIM_DIR) && vsim

VSIM_OPT_COMMON += -do $(RUN_DIR)/script_modelsim.tcl -onfinish final

VSIM_OPT_CMD     = -c
VSIM_OPT_CMD    += -onfinish exit

VSIM_OPT_GUI     = -gui -onfinish stop

sim_clean:
	rm -rfd $(VSIM_DIR)
	rm -rfd log

sim_dir: sim_clean
	mkdir $(VSIM_DIR)
	mkdir log

sim_cmd: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_CMD)

sim_gui: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_GUI) &

########################################################
# compiling  - program

PROG_NAME ?= 00_counter
COMP_KEY  ?= -march=rv32i -mabi=ilp32

prog_form:
	rm -rfd program/$(PROG_NAME)/main.o
	echo @00000000 > program_file/program.hex
	cat program_file/main.elf | sed -rn 's/\s+[a-f0-9]+:\s+([a-f0-9]*)\s+.*/\1/p' >> program_file/program.hex

prog_compile_win:
	riscv-none-embed-gcc program/$(PROG_NAME)/main.S -c -o program/$(PROG_NAME)/main.o $(COMP_KEY)
	mkdir -p program_file
	riscv-none-embed-objdump -D -z -l program/$(PROG_NAME)/main > program_file/main.elf
	
prog_compile_lin:
	riscv64-unknown-elf-gcc program/$(PROG_NAME)/main.S -c -o program/$(PROG_NAME)/main $(COMP_KEY)
	mkdir -p program_file
	riscv64-unknown-elf-objdump -D -z -l program/$(PROG_NAME)/main > program_file/main.elf

prog_comp_win: \
	prog_compile_win \
	prog_form 
	
prog_comp_lin: \
	prog_compile_lin \
	prog_form 

test_comp_win_c:
	mkdir -p program_file
	riscv-none-embed-as program/startup/boot.S -c -o program_file/boot.o -march=rv32i -mabi=ilp32
	riscv-none-embed-gcc program/$(PROG_NAME)/main.c -c -o program_file/main.o -march=rv32i -mabi=ilp32
	riscv-none-embed-ld -o program_file/main.elf -Map program_file/main.map -T program/startup/program.ld program_file/boot.o program_file/main.o -b elf32-littleriscv
	riscv-none-embed-objdump -S -w --disassemble-zeroes program_file/main.elf > program_file/main.lst
	riscv-none-embed-objcopy program_file/main.elf program_file/program.ihex -O ihex
	python program/startup/ihex2hex.py

test_comp_win_asm:
	mkdir -p program_file
	riscv-none-embed-as program/startup/boot.S -c -o program_file/boot.o -march=rv32i -mabi=ilp32
	riscv-none-embed-gcc program/$(PROG_NAME)/main.S -c -o program_file/main.o -march=rv32i -mabi=ilp32
	riscv-none-embed-ld -o program_file/main.elf -Map program_file/main.map -T program/startup/program.ld program_file/boot.o program_file/main.o -b elf32-littleriscv
	riscv-none-embed-objdump -S -w --disassemble-zeroes program_file/main.elf > program_file/main.lst
	riscv-none-embed-objcopy program_file/main.elf program_file/program.ihex -O ihex
	python program/startup/ihex2hex.py

prog_clean:
	rm -rfd $(PWD)/program_file

########################################################
# synthesis - default board only

MAKEFILE_PATH   = $(PWD)/board
SYNTH_DIR       = $(PWD)/synth_$(BOARD)
SYNTH_TEMPLATE  = $(BRD_DIR)/$(BOARD)
CABLE_NAME 	   ?= "USB-Blaster"

synth_clean:
	rm -rfd $(SYNTH_DIR)

synth_create: synth_clean
	cp -r  $(SYNTH_TEMPLATE) $(SYNTH_DIR)

synth_build_q:
	quartus_sh --flow compile $(PWD)/synth_$(BOARD)/$(BOARD)

synth_gui_q:
	quartus $(PWD)/synth_$(BOARD)/$(BOARD).qpf &

synth_load_q:
	quartus_pgm -c $(CABLE_NAME) -m JTAG -o "p;synth_$(BOARD)/output_files/$(BOARD).sof"

########################################################
# synthesis - all the supported boards

BOARD_NAME         = $@
BOARD_TEMPLATE_DIR = $(BRD_DIR)/$(BOARD_NAME)
BOARD_BUILD_DIR    = $(PWD)/synth_$(BOARD_NAME)

$(BOARDS_SUPPORTED):
	rm -rfd $(BOARD_BUILD_DIR)
	cp -r  $(BOARD_TEMPLATE_DIR) $(BOARD_BUILD_DIR)
	make -C $(BOARD_BUILD_DIR) create
	make -C $(BOARD_BUILD_DIR) build

board_all: $(BOARDS_SUPPORTED)

board_clean:
	rm -rfd $(PWD)/synth_*

########################################################
# log 

log_clean:
	rm -rfd $(PWD)/log/*
