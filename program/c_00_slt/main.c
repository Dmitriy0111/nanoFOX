/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.13
*  Language        :   C
*  Description     :   This is test program for slt command
*  Copyright(c)    :   2019 Vlasov D.V.
*/


void main (void)
{
    __asm("lui s1, 2");
    __asm("lui s2, 3");
    __asm("slt s3, s1, s2");
    
    while(1)
    {
        ;
    }
}