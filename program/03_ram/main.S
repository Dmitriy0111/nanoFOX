# 
#  File            :   main.S
#  Autor           :   Vlasov D.V.
#  Data            :   2018.12.02
#  Language        :   Assembler
#  Description     :   This is example for working with ram
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
# 

.section    .text

_start:     beq     zero, zero, _start      # go to _start label
