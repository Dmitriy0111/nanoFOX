/*
    This is test program for counter
*/

void delay(void)
{
    int del;
    for(del = 0; del < 10; del++);
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