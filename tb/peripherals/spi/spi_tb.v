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
//Description : Simple RV32I processor
//              With 5 stage pipeline
//              Brach always not taken
// 
//File type   : Verilog RTL
//Description : SPI
//
////////////////////////////////////////////////////////////////////
`define wait_clk @(posedge clk)
`define start tx_en<=1'b1;
`define stop tx_en<=1'b0;
`define mode0 cpha<=1'b0;cpol<=1'b0;
`define mode1 cpha<=1'b1;cpol<=1'b0;
`define mode2 cpha<=1'b0;cpol<=1'b1;
`define mode3 cpha<=1'b1;cpol<=1'b1;
`define txmit tx_en<=1'b1;@(posedge clk);tx_en<=1'b0;
`define WID 8
module spi_tb();


reg clk;
reg rstn;
reg cpol;
reg cpha;
wire sck;
wire csn;
wire ready;
wire [`WID-1:0] rx_data;
wire rx_valid;
reg [`WID-1:0] tx_data;
reg tx_en;
reg tb_sdo;
wire tb_sdi;

always begin
	clk<=1'b0;
	#10;
	clk<=1'b1;
	#10;
end
initial begin
    tb_sdo<=1'b1;
	rstn<=1'b0;
	tx_en<=1'b0;
	`mode0
	#100;
	rstn<=1'b1;
	#100;
	`mode0
	`wait_clk;
	tx_data<=8'h90;
	`txmit
	#500;
	`mode1
	`wait_clk;
	tx_data<=8'h91;
	`txmit
	#500;
	`mode2
	`wait_clk;
	tx_data<=8'h92;
	`txmit
	#500;
	`mode3
	`wait_clk;
	tx_data<=8'h93;
	`txmit
	#500;
end

spi #(
    .P_WIDTH(`WID)
)
DUT0(
	.i_clk(clk),
	.i_rstn(rstn),
        .i_cpol(cpol),
	.i_cpha(cpha),
        .o_sck(sck),
	.i_sdi(tb_sdi),
	.o_sdo(tb_sdi),
	.o_csn(csn),
        .o_ready(ready),
        .i_tx_en(tx_en),
	.i_tx_data(tx_data),
        .o_rx_data(rx_data),
	.o_rx_valid(rx_valid)
);




endmodule
