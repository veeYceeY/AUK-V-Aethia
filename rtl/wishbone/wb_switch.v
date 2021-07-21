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
//Description : wishbone mux switch
//
////////////////////////////////////////////////////////////////////


module wb_switch( 
	i_clk,i_rstn,

	o_s2m_wb,i_m2s_wb,

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

input  `WB_M2S  i_m2s_wb;
output `WB_S2M  o_s2m_wb;

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


assign o_s2m_wb= i_m2s_wb`addr <32'h00010000 ? i_s2m0_wb :
		i_m2s_wb`addr <32'h00100000 ? i_s2m1_wb :
		i_m2s_wb`addr <32'h00100100 ? i_s2m2_wb :
		i_m2s_wb`addr <32'h00100200 ? i_s2m3_wb :
		i_m2s_wb`addr <32'h00800000 ? i_s2m4_wb :
		                              i_s2m5_wb ;
					      
assign o_m2s0_wb= i_m2s_wb`addr <32'h00010000 ? i_m2s_wb :
		 i_m2s_wb`addr <32'h00100000 ? 'h0:
		 i_m2s_wb`addr <32'h00100100 ? 'h0:
		 i_m2s_wb`addr <32'h00100200 ? 'h0:
		 i_m2s_wb`addr <32'h00800000 ? 'h0:
		                               'h0 ;

assign o_m2s1_wb= i_m2s_wb`addr <32'h00010000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100000 ? (i_m2s_wb & `MASK_ADDR) | {i_m2s_wb`addr-32'h00010000,39'h0} :
		 i_m2s_wb`addr <32'h00100100 ? 'h0 :
		 i_m2s_wb`addr <32'h00100200 ? 'h0 :
		 i_m2s_wb`addr <32'h00800000 ? 'h0 :
		                               'h0 ;

assign o_m2s2_wb= i_m2s_wb`addr <32'h00100000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100100 ?  (i_m2s_wb & `MASK_ADDR) | {i_m2s_wb`addr-32'h00100000,39'h0} :
		 i_m2s_wb`addr <32'h00100200 ? 'h0 :
		 i_m2s_wb`addr <32'h00800000 ? 'h0 :
		                               'h0 ;

assign o_m2s3_wb= i_m2s_wb`addr <32'h00010000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100100 ? 'h0 :
		 i_m2s_wb`addr <32'h00100200 ? (i_m2s_wb & `MASK_ADDR) | {i_m2s_wb`addr-32'h00100100,39'h0} :
		 i_m2s_wb`addr <32'h00800000 ? 'h0 :
		                               'h0 ;

assign o_m2s4_wb= i_m2s_wb`addr <32'h00010000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100100 ? 'h0 :
		 i_m2s_wb`addr <32'h00100200 ? 'h0 :
		 i_m2s_wb`addr <32'h08000000 ? (i_m2s_wb & `MASK_ADDR) | {i_m2s_wb`addr-32'h00100200,39'h0} :
		                               'h0 ;

assign o_m2s5_wb= i_m2s_wb`addr <32'h00010000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100000 ? 'h0 :
		 i_m2s_wb`addr <32'h00100100 ? 'h0 :
		 i_m2s_wb`addr <32'h00100200 ? 'h0 :
		 i_m2s_wb`addr <32'h00800000 ? 'h0 : 
		                               (i_m2s_wb & `MASK_ADDR) | {i_m2s_wb`addr-32'h00800000,39'h0} ;
endmodule
