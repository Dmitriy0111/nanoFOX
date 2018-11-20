/*
*  File            :   nf_control_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.20
*  Language        :   SystemVerilog
*  Description     :   This is controll unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_cpu.svh"

module nf_control_unit
(
    input   logic   [6 : 0]     opcode,
    input   logic   [2 : 0]     funct3,
    input   logic   [6 : 0]     funct7,
    output  logic               srcBsel,
    output  logic               we,
    output  logic   [31 : 0]    ALU_Code
);

always_comb
begin
    we = '0;
    ALU_Code = '0;
    srcBsel = '0;
    casex( { opcode , funct3 } )
        { `C_SLLI , `F_SLLI } : begin we = '1; ALU_Code = `ALU_SLLI; srcBsel = '1; end
        { `C_ADDI , `F_ADDI } : begin we = '1; ALU_Code = `ALU_ADD;  srcBsel = '1; end
        { `C_ADD  , `F_ADD  } : begin we = '1; ALU_Code = `ALU_ADD;  srcBsel = '0; end
        { `C_OR   , `F_OR   } : begin we = '1; ALU_Code = `ALU_OR;   srcBsel = '0; end
        { `C_BEQ  , `F_BEQ  } : begin we = '1; ALU_Code = `C_ADD;    srcBsel = '0; end
        { `C_LUI  , `F_ANY  } : begin we = '1; ALU_Code = `ALU_LUI;  srcBsel = '0; end
    endcase
end

endmodule : nf_control_unit
