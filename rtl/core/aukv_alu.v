 ///////////////////////////////////////////////////////////////////
//       _____         __            ____   ____
//      /  _  \  __ __|  | __        \   \ /   /
//     /  /_\  \|  |  \  |/ /  ______ \   Y   / 
//    /    |    \  |  /    <  /_____/  \     /  
//    \____|__  /____/|__|_ \           \___/   
//            \/           \/                   
//
///////////////////////////////////////////////////////////////////
//Author      : Vipin.VC
//Project     : Auk-V
//Description : RV32I CPU
//              With 5 stage pipeline
//              Brach always not taken
// 
//File type   : Verilog RTL
//Description : ALU
//
////////////////////////////////////////////////////////////////////

module aukv_alu ( i_clk,i_rstn,
         i_operation,
         i_rs1,i_rs2,
         o_rd
        );

input i_clk;
input i_rstn;
input [2:0] i_operation;
input [31:0] i_rs1;
input [31:0] i_rs2;

output [31:0] o_rd;


reg [31:0] result;
reg [31:0] sum;
reg [31:0] dif;
reg [31:0] anded;
reg [31:0] ored;
reg [31:0] xored;
reg [31:0] shiftleft;
reg [31:0] shiftright_logic;
reg [31:0] shiftright_arith;
reg [31:0] zero;
reg [31:0] sign;
reg [31:0] shamt;
reg [31:0] s_lt;


assign o_rd =  ~i_rstn             ? 32'd0           :
                i_operation == 4'd0 ? i_rs1 +   i_rs2 :
                i_operation == 4'd1 ? i_rs1 -   i_rs2 :
                i_operation == 4'd2 ? i_rs1 |   i_rs2 :
                i_operation == 4'd3 ? i_rs1 &   i_rs2 :
                i_operation == 4'd4 ? i_rs1 ^   i_rs2 :
                i_operation == 4'd5 ? i_rs1 <<  i_rs2 :
                i_operation == 4'd6 ? i_rs1 >>> i_rs2 :
                i_operation == 4'd7 ? i_rs1 >>  i_rs2 : 
                32'd0;

endmodule