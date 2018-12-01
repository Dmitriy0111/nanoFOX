riscv64-unknown-elf-gcc main.S -c -o main -march=rv64ima -mabi=lp64
riscv64-unknown-elf-objdump -D -z main > main.elf
rm main
