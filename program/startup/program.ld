stack_words = 64;
stack_size  = 4 * stack_words;
ram_depth   = 0x400;
ram_size    = 4 * ram_depth;

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
    .stack ( ORIGIN(ram) + LENGTH(ram) - stack_size ): {
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