/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.03.03
*  Language        :   C
*  Description     :   This is simple counter example
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

void delay(void)
{
    int del = 10;
    while(del != 0)
        del--;
}

void main (void)
{
    int i = 0;
    while(1)
    {
        delay();
        i++;
    }
}