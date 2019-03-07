# this is counter program example

.section    .text

_start:     lui     t0, 0                   # t0 = 0 ; clear t0   
            lui     t1, 0                   # t0 = 0 ; clear t0  
            addi    t1, t1, %lo(-3)      
            lui     t2, 0                   # t0 = 0 ; clear t0   
            addi    t2, t2, %lo(-1)    
counter:    addi    t0, t0, 1               # t0 = t0 + 1 ; addition t0 with 1
            beq     zero, zero, counter     # go to counter label
