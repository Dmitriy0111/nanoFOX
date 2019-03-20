/*
*  File            :   main.c
*  Autor           :   Vlasov D.V.
*  Data            :   2019.03.03
*  Language        :   C
*  Description     :   This is number's of leonardo example
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

void main (void)
{
    int i_0 = 1;
    int i_1 = 1;
    int leo = 0;
    while(1)
    {
        leo = i_1 + i_0 + 1;
        i_0 = i_1;
        i_1 = leo;
    }
}