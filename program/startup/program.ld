
MEMORY
{
    ram : ORIGIN = 0x00000000, LENGTH = 0x100
}

SECTIONS
{
    .text : { *(.text*) } > ram
}