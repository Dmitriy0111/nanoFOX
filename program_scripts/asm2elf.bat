riscv-none-embed-gcc main.S -c -o main -march=rv64ima -mabi=lp64
riscv-none-embed-objdump -D -z main > main.elf
erase main
