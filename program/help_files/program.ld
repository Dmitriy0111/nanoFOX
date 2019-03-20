ram_depth   = 64;
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
        disable comment in listing file
    */
    /DISCARD/ : {
    *(.comment .comment.*)
    }
}