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
//Description : Uart transmitter 
//
////////////////////////////////////////////////////////////////////
module uart_tx(
		i_clk,i_rstn,
		i_en,i_parity,
		i_txen,
		i_txdata,o_txclk,
		o_done,o_tx
		);


input i_clk;
input i_rstn;
input i_en;
input i_parity;
input i_txen;
input [7:0] i_txdata;
output o_txclk;
output o_done;
output o_tx;
reg txen_d1;
wire txen_lth;
wire sh_en;
wire done;
reg [3:0] div_count;
reg [3:0] count;
reg tx_clk;
reg [9:0] tx_buff;



always@(posedge tx_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		txen_d1<=1'b0;
	end else begin
		txen_d1<=i_txen;
	end
end

assign txen_lth =  i_txen & (~txen_d1) ;

always@(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		div_count<=4'h0;
		tx_clk<=1'b0;
	end else begin
		if (div_count < 4'hf) begin
			div_count<=div_count+1;
			tx_clk<=1'b0;
		end else begin
			div_count<=4'h0;
			tx_clk<= 1'h1;
		end
	end
end

always@(posedge tx_clk,negedge i_rstn) begin
        if (~i_rstn) begin
                count<=4'h0;
        end else begin
            if(i_en) begin
                if(txen_lth) begin
                    count<=4'hA;  
                end else if(count>4'h0) begin
				    count<=count-1;
				end
			end
        end
end

assign sh_en = count>4'h0 ;
assign done  = count==4'h0;

always@(posedge tx_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		tx_buff<=10'h3ff;
	end else begin
		if(i_en) begin
			if(txen_lth) begin
				tx_buff<={1'b1,i_txdata,1'b0};
			end else if (sh_en) begin
				tx_buff<={1'b1,tx_buff[9:1]};
			end
		end
	end
end
assign o_txclk=tx_clk;
assign o_tx= tx_buff[0];
assign o_done= done & (~i_txen);

endmodule