/*
    This is test program for counter
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