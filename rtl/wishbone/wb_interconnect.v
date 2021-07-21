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
//Description : interconnect
//
////////////////////////////////////////////////////////////////////


module wb_interconnect( 
	i_clk,i_rstn,

	i_m2s0_wb,o_s2m0_wb,
	i_m2s1_wb,o_s2m1_wb,

	o_m2s0_wb,i_s2m0_wb,
	o_m2s1_wb,i_s2m1_wb,
	o_m2s2_wb,i_s2m2_wb,
	o_m2s3_wb,i_s2m3_wb,
	o_m2s4_wb,i_s2m4_wb,
	o_m2s5_wb,i_s2m5_wb
);


`include "package.vh"

input i_clk;
input i_rstn;

input `WB_M2S i_m2s0_wb;
input `WB_M2S i_m2s1_wb;
output `WB_S2M o_s2m0_wb;
output `WB_S2M o_s2m1_wb;

output `WB_M2S  o_m2s0_wb;
input `WB_S2M  i_s2m0_wb;

output `WB_M2S  o_m2s1_wb;
input `WB_S2M  i_s2m1_wb;

output `WB_M2S  o_m2s2_wb;
input `WB_S2M  i_s2m2_wb;

output `WB_M2S  o_m2s3_wb;
input `WB_S2M  i_s2m3_wb;

output `WB_M2S  o_m2s4_wb;
input `WB_S2M  i_s2m4_wb;

output `WB_M2S  o_m2s5_wb;
input `WB_S2M  i_s2m5_wb;

wire `WB_M2S  arb0_m2s_wb;
wire `WB_S2M  sw0_s2m_wb;


wb_arbiter ARB0( .i_clk(i_clk),
            .i_rstn(i_rstn),
            
            .i_m2s0_wb(i_m2s0_wb),
            .o_s2m0_wb(o_s2m0_wb),
            .i_m2s1_wb(i_m2s1_wb),
            .o_s2m1_wb(o_s2m1_wb),
            
            .i_s2m_wb(sw0_s2m_wb),
            .o_m2s_wb(arb0_m2s_wb)
);

wb_switch SW0( 
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.o_s2m_wb(sw0_s2m_wb),
	.i_m2s_wb(arb0_m2s_wb),
	.o_m2s0_wb(o_m2s0_wb),
	.i_s2m0_wb(i_s2m0_wb),
	.o_m2s1_wb(o_m2s1_wb),
	.i_s2m1_wb(i_s2m1_wb),
	.o_m2s2_wb(o_m2s2_wb),
	.i_s2m2_wb(i_s2m2_wb),
	.o_m2s3_wb(o_m2s3_wb),
	.i_s2m3_wb(i_s2m3_wb),
	.o_m2s4_wb(o_m2s4_wb),
	.i_s2m4_wb(i_s2m4_wb),
	.o_m2s5_wb(o_m2s5_wb),
	.i_s2m5_wb(i_s2m5_wb)
);
endmodule
