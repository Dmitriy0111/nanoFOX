/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.05.14
*  Language        :   C
*  Description     :   This is test program for bltu command
*  Copyright(c)    :   2019 Vlasov D.V.
*/

volatile int x = 0;

void main (void)
{
    while(1)
    {
        if(x < 20)  // WHY it doesnt work??? WHY jal instruction before sw ???
            x++;
        else
            x = 0; 
    }
}