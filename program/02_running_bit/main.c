/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.03.03
*  Language        :   C
*  Description     :   This is running bit example
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

void main (void)
{
    volatile int i = 1;
    while(1)
    {
        i = i << 1;
        if( i == 0 )
            i = 1;
    }
}