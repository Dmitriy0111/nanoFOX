/*
*  File            :   nf_bt_class.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.03.11
*  Language        :   SystemVerilog
*  Description     :   This is base test class
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

package NF_BTC; // base test class

class nf_bt_class;

    string  name;

    task build();
        $display("%s build sucessfull!",name);
    endtask : build

    task run();
        $display("%s run sucessfull!",name);
    endtask : run

    string reg_list [0  : 31] = {
                                    "zero ",
                                    "ra   ",
                                    "sp   ",
                                    "gp   ",
                                    "tp   ",
                                    "t0   ",
                                    "t1   ",
                                    "t2   ",
                                    "s0/fp",
                                    "s1   ",
                                    "a0   ",
                                    "a1   ",
                                    "a2   ",
                                    "a3   ",
                                    "a4   ",
                                    "a5   ",
                                    "a6   ",
                                    "a7   ",
                                    "s2   ",
                                    "s3   ",
                                    "s4   ",
                                    "s5   ",
                                    "s6   ",
                                    "s7   ",
                                    "s8   ",
                                    "s9   ",
                                    "s10  ",
                                    "s11  ",
                                    "t3   ",
                                    "t4   ",
                                    "t5   ",
                                    "t6   "
                                };

endclass : nf_bt_class

endpackage : NF_BTC
