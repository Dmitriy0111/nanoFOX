/*
*  File            :   nf_ram.h
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.25
*  Language        :   C
*  Description     :   This is constants for working with RAM
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

// RAM registers addr
#define     NF_RAM_ADDR     0x00000000
// RAM registers
#define     NF_RAM          (* (volatile unsigned *) NF_RAM_ADDR )
