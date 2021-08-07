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

module spi(
	i_clk,i_rstn,
	i_cpol,i_cpha,
	o_sck,i_sdi,o_sdo,o_csn,
	o_ready,
	i_tx_en,i_tx_data,
	o_rx_data,o_rx_valid
);

parameter P_WIDTH = 32;

input i_clk;
input i_rstn;
output o_sck;
input i_sdi;
output o_sdo;
output o_csn;
input i_tx_en;
input [P_WIDTH-1 :0] i_tx_data;
output o_rx_valid;
output [P_WIDTH-1 :0] o_rx_data;
output o_ready;

input i_cpha;
input i_cpol;

reg [P_WIDTH-1:0] tx_buff;
reg [P_WIDTH-1:0] rx_buff;

reg [$clog2(P_WIDTH):0] count;

wire clk_p;
wire clk_n;
wire clk_rx_ph0;
wire clk_rx_ph1;
wire clk_tx_ph0;
wire clk_tx_ph1;
wire clk_rx;
wire clk_tx;
wire clk_out_pol0;
wire clk_out_pol1;
wire clk_out;
reg rx_valid;
assign clk_p = i_clk;
assign clk_n = ~i_clk;
//assign clk_rx_ph0 = i_cpha ? clk_p : clk_n;
//assign clk_rx_ph1 = i_cpha ? clk_n : clk_p;

//assign clk_tx_ph0 = i_cpha ? clk_n : clk_p;
//assign clk_tx_ph1 = i_cpha ? clk_p : clk_n;

assign clk_rx = i_cpha ? clk_n : clk_p;
assign clk_tx = i_cpha ? clk_p : clk_n;

assign clk_out = i_cpol ? clk_n | (~shift_en) : clk_p &(shift_en);



always @(posedge clk_tx ,negedge i_rstn) begin
	if(~i_rstn) begin
		count<='b0;
	end else begin
		if (count==0) begin
			if(i_tx_en) begin
				count<=P_WIDTH;
			end
		end else begin
			count<=count-1;
		end
	end
end
assign shift_en = count !=0;
assign csn=count==0;
always @(posedge clk_tx,negedge i_rstn) begin
	if(~i_rstn) begin
		tx_buff<=1'b0;
	end else begin
		if(~shift_en) begin
			tx_buff<=i_tx_data;
		end else begin
			tx_buff<={1'b0,tx_buff[P_WIDTH-1:1]};
		end
	end
end
always @(posedge clk_rx,negedge i_rstn) begin
	if(~i_rstn) begin
		rx_buff<='b0;
	end else begin
		if(~csn) begin
			rx_buff<={i_sdi,rx_buff[P_WIDTH-1:1]};
		end
	end
end
always @(posedge clk_tx,negedge i_rstn) begin
	if(~i_rstn) begin
		rx_valid<=1'b0;
	end else begin
		rx_valid<=count==1;
	end
end
assign o_sck=clk_out;
assign o_sdo=tx_buff[0];
assign o_csn=csn;
assign o_rx_valid = rx_valid;
assign o_ready = csn;
assign o_rx_data = rx_buff;
endmodule
