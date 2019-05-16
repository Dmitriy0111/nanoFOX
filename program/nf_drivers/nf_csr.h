/*
*  File            :   nf_csr.h
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.16
*  Language        :   C
*  Description     :   This defins for working with csr
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

#define read_csr_v( csr ) ( {                           /* read csr value           */  \
    unsigned long reg;                                  /* output variable          */  \
    asm volatile ("csrr %0, " #csr : "=r"(reg) );       /* inline assembly          */  \
    reg;                                                /* return output variable   */  \
} )

#define write_csr_v( csr , val ) ( {                    /* write value in csr       */  \
    asm volatile ("csrw " #csr ", %0" :: "rK"(val));    /* inline assembly          */  \
} )
