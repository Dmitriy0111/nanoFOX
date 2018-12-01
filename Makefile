
help:
	$(info make help         - show this message)
	$(info make clean        - delete synth and simulation folders)
	$(info make sim          - the same as sim_gui)
	$(info make icarus       - the same as icarus_cmd)
	$(info make synth        - clean, create the board project and run the synthesis (for default board))
	$(info make open         - the same as synth_gui)
	$(info make load         - the same as synth_load)
	$(info make sim_cmd      - run simulation in Modelsim (console mode))
	$(info make sim_gui      - run simulation in Modelsim (gui mode))
	$(info make icarus_cmd   - run simulation in Icarus Verilog (console mode))
	$(info make icarus_gui   - run simulation in Icarus Verilog (gui mode))
	$(info make synth_create - create the board project)
	$(info make synth_build  - build the board project)
	$(info make synth_gui    - open the board project)
	$(info make synth_load   - program the default FPGA board)
	$(info make board_all    - run synthesis for all the supported boards)
	$(info Open and read the Makefile for details)
	@true

PWD     := $(shell pwd)
BRD_DIR  = $(PWD)/board
RUN_DIR  = $(PWD)/run
RTL_DIR  = $(PWD)/rtl
TB_DIR   = $(PWD)/tb

BOARDS_SUPPORTED ?= de0_nano
BOARD            ?= de0_nano

########################################################
# common make targets

show_pwd:
	PWD

clean: \
	sim_clean \
	board_clean \
	log_clean
	icarus_clean \
	xsim_clean \

sim_all: \
	sim_cmd \
	xsim_cmd \
	icarus_cmd

sim: sim_gui

xsim: xsim_cmd

icarus: icarus_cmd

create: synth_create

synth: \
	synth_clean \
	synth_create \
	synth_build

load: synth_load

open: synth_gui

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

sim_dir: sim_clean
	mkdir $(VSIM_DIR)

sim_cmd: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_CMD)

sim_gui: sim_dir
	$(VSIM_BIN) $(VSIM_OPT_COMMON) $(VSIM_OPT_GUI) &


########################################################
# simulation - Xilinx Vivado Simulator
#
#XSIM_DIR = $(PWD)/sim_xsim
#
#XVLOG_BIN = cd $(XSIM_DIR) && xvlog
#XELAB_BIN = cd $(XSIM_DIR) && xelab
#XSIM_BIN  = cd $(XSIM_DIR) && xsim
#
#xsim_clean:
#	rm -rfd $(XSIM_DIR)
#
#xsim_dir: xsim_clean
#	mkdir $(XSIM_DIR)
#
#xsim_compile: xsim_dir
#	$(XVLOG_BIN)    $(RTL_DIR)/*.v
#ifneq (,$(wildcard $(RTL_DIR)/*.sv))
#	$(XVLOG_BIN) --sv $(RTL_DIR)/*.sv
#endif
#	$(XVLOG_BIN) --sv $(TB_DIR)/*.sv
#	$(XELAB_BIN) --incr --debug typical --relax --mt 2 testbench -s tb_sim
#
#xsim_cmd: xsim_compile
#	$(XSIM_BIN) --runall tb_sim
#
#xsim_gui: xsim_compile
#	$(XSIM_BIN) --gui --tl tb_sim

########################################################
# simulation - Icarus Verilog

ISIM_DIR = $(PWD)/sim_icarus

IVER_BIN = cd $(ISIM_DIR) && iverilog
VVP_BIN  = cd $(ISIM_DIR) && vvp
GTK_BIN  = cd $(ISIM_DIR) && gtkwave

IVER_OPT  = -s testbench
IVER_OPT += -g2005-sv
IVER_OPT += -I $(RTL_DIR)
IVER_OPT += $(RTL_DIR)/*.v
IVER_OPT += $(TB_DIR)/*.sv
ifneq (,$(wildcard $(RTL_DIR)/*.sv))
	IVER_OPT += $(RTL_DIR)/*.sv
endif

icarus_clean:
	rm -rfd $(ISIM_DIR)

icarus_cmd: icarus_clean
	mkdir $(ISIM_DIR)
	$(IVER_BIN) $(IVER_OPT)
	$(VVP_BIN) -la.lst -n a.out -vcd

icarus_gui: icarus_cmd
	$(GTK_BIN) dump.vcd

########################################################
# synthesis - default board only

MAKEFILE_PATH = $(PWD)/board
SYNTH_DIR      = $(PWD)/synth_$(BOARD)
SYNTH_TEMPLATE = $(BRD_DIR)/$(BOARD)

synth_clean:
	rm -rfd $(SYNTH_DIR)

synth_create: synth_clean
	cp -r  $(SYNTH_TEMPLATE) $(SYNTH_DIR)
	make -C $(MAKEFILE_PATH) create

synth_build:
	make -C $(MAKEFILE_PATH) build

synth_gui:
	make -C $(MAKEFILE_PATH) open

synth_load:
	make -C $(MAKEFILE_PATH) load

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
