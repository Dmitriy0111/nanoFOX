stack_words = 64;
stack_size  = 4 * stack_words;
ram_depth   = 0x400;
ram_size    = 4 * ram_depth;
data_size   = 0x100;

MEMORY
{
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = ram_size
}

SECTIONS
{
    /*
        program region
    */
    .text : { *(.text*) } > ram
    /*
        stack region
    */
    /*
        data region
    */
    .data ( ORIGIN(ram) + LENGTH(ram) - data_size ):{
        *(.text*)
    } > ram
    .stack ( ORIGIN(ram) + LENGTH(ram) - data_size - stack_size ): {
        _stack_start = .;
        . += stack_size;
        _stack_end = .;
    } > ram
    /*
        disable comment in listing file
    */
    /DISCARD/ : {
    *(.comment .comment.*)
    }
}