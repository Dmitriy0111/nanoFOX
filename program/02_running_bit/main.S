# this is running bit program example

.section    .text

_start:     lui     t0, 1                   # t0 = 0 ; clear t0         
counter:    slli    t0, t0, 1               # t0 = t0 + 1 ; addition t0 with 1
            beq     t0, zero, _start        # go to counter label
            beq     zero, zero, counter     # go to _start label
