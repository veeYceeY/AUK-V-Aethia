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
         o_rd,
	 i_cmp_a,i_cmp_b,i_cmp_sign,
	 o_lt,o_ge,o_eq,o_ne
        );

input i_clk;
input i_rstn;
input [2:0] i_operation;
input [31:0] i_rs1;
input [31:0] i_rs2;

output [31:0] o_rd;

input [31:0] i_cmp_a;
input [31:0] i_cmp_b;
input i_cmp_sign;
output o_lt;
output o_ge;
output o_eq;
output o_ne;
wire lt_u;
wire ge_u;
wire eq_u;
wire ne_u;
wire lt_s;
wire ge_s;
wire eq_s;
wire ne_s;

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



assign lt_u = i_cmp_a < i_cmp_b? 1'b1 : 1'b0;
assign ge_u = i_cmp_a >= i_cmp_b? 1'b1 : 1'b0;
assign eq_u = i_cmp_a == i_cmp_b? 1'b1 : 1'b0;
assign ne_u = i_cmp_a != i_cmp_b? 1'b1 : 1'b0;

assign lt_s = $signed(i_cmp_a) < $signed(i_cmp_b)? 1'b1 : 1'b0;
assign ge_s = $signed(i_cmp_a) >= $signed(i_cmp_b)? 1'b1 : 1'b0;
assign eq_s = $signed(i_cmp_a) == $signed(i_cmp_b)? 1'b1 : 1'b0;
assign ne_s = $signed(i_cmp_a) != $signed(i_cmp_b)? 1'b1 : 1'b0;

assign o_lt = i_cmp_sign ? lt_s : lt_u;
assign o_ge = i_cmp_sign ? ge_s : ge_u;
assign o_eq = i_cmp_sign ? eq_s : eq_u;
assign o_ne = i_cmp_sign ? ne_s : ne_u;


endmodule
