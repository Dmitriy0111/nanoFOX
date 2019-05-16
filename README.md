# **nanoFOX**
    A small RISC-V CPU core. This is a pipeline version of CPU with AHB (full command list RV32I).
    
## Supported instructions:
*   lui
*   auipc
*   jal
*   jalr
*   beq
*   bne
*   blt
*   bge
*   bltu
*   bgeu
*   lb
*   lh
*   lw
*   lbu
*   lhu
*   sb
*   sh
*   sw
*   addi
*   slti
*   sltiu
*   xori
*   ori
*   andi
*   slli
*   srli
*   srai
*   add
*   sub
*   sll
*   slt
*   sltu
*   xor
*   srl
*   sra
*   or
*   and
*   csrrw
*   csrrs
*   csrrc
*   csrrwi
*   csrrsi
*   csrrci

## Quickstart:
For loading project with git program:

    $ git clone https://github.com/Dmitriy0111/nanoFOX.git 
    $ cd nanoFOX 
    $ git checkout 03_pipe_risc_v_cpu_fc

Or download project from GitHub site <a href="https://github.com/Dmitriy0111/nanoFOX">03_pipe_risc_v_cpu_fc</a>

For working with project install:
*   make
*   <a href="https://www.intel.ru/content/www/ru/ru/software/programmable/quartus-prime/download.html">Quartus Prime and Modelsim</a>
*   <a href="https://www.python.org/downloads/">Python</a>
*   <a href="https://github.com/gnu-mcu-eclipse/riscv-none-gcc/releases">RISC-V tools</a>

**Impotant:** Before starting simulation or synthesis process make compilation program or create "program_file" folder and copy one of program.hex files from program folder.

## Compilation program:
*   **set PROG_NAME="name of folder with main program"** is used for setting current program. For example "set PROG_NAME=02_running_bit";
*   **make prog_comp_c** is used for compiling C code program;
*   **make prog_comp_asm** is used for compiling Assembler code program;
*   **make prog_clean** is used for cleaning compilation results folder.

## Simulation:
*   **make sim_dir** is used for creating simulation folder;
*   **make sim_clean** is used for cleaning simulation result;
*   **make sim_cmd** is used for starting simulation in command line (CMD) mode;
*   **make sim_gui** is used for starting simulation in graphical user interface (GUI) mode.

If log_txt or log_html set as '1 and log_en set as '1 (tb/nf_tb.svh) then you can see simulation results in log folder (log/log.log or log/log.html).

## Synthesis:
*   **make synth_create** is used for creating synthesis folder for default board;
*   **make synth_clean** is used for cleaning synthesis folder;
*   **make synth_build_q** is used for building project in Quartus;
*   **make synth_gui_q** is used for open project in Quartus;
*   **make synth_load_q** is used for loading bitstream in CPLD/FPGA with Quartus.

## Core diagram:
![cpu_system](doc/cpu_system.jpg)

## Boards support:
simple cpu nanoFOX currently works on these FPGA boards:
<ol>
<li>Storm_IV_E6_V2 ( Altera Cyclone IV FPGA )</li>
<li>rz_easyFPGA_A2_1 ( Altera Cyclone IV FPGA )</li>
<li><a href="https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=234&No=1021">Terasic DE10-Lite ( Altera MAX10 FPGA )</a></li>
<li><a href="https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=593">Terasic DE0-Nano ( Altera Cyclone IV FPGA )</a></li>
</ol>

## Repository contents:
| Folder        | Contents                                          |
| :------------ | :------------------------------------------------ |
| board         | Top levels of design for fpga development boards  |
| brd_rtl       | Auxiliary modules for top levels                  |
| doc           | RISC-V ISA 2.2                                    |
| inc           | Header files for design                           |
| program       | Examples of programs                              |
| rtl           | Core source files                                 |
| run           | Scripts for simulation                            |
| tb            | Testbenches for core and separate parts           |
| other         | Readme and license files, Makefile                |

## Planns:
*   Adding Xilinx support
*   Adding other Altera boards support
*   Adding docs
