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
//Description : Uart rx 
//
////////////////////////////////////////////////////////////////////

`define ST_START 3'b000
`define ST_ALIGN 3'b001
`define ST_DATA 3'b010
`define ST_PARITY 3'b011
`define ST_STOP  3'b100


module uart_rx (
			i_clk,i_rstn,
			i_en,
			o_clk,
			o_rx_data,o_rx_valid,

			i_rx
		);

input i_clk;
input i_rstn;
input i_en;
input i_rx;

output o_clk;
output [7:0] o_rx_data;
output o_rx_valid;

reg [2:0] rx_state;
reg [7:0] rx_buff;
reg err;
reg rx_valid;
reg rx_cdc0;
reg rx_cdc1;
reg rx_valid_cdc0;
reg rx_valid_cdc1;

reg [7:0] rx_data;
reg [7:0] rx_data_cdc0;
reg [7:0] rx_data_cdc1;

reg [7:0] count;
reg parity;
wire rx_clk;
reg rx_clk_d;
reg [31:0] div_count;
reg [31:0] align_count;
reg [31:0] align_value;


always@(posedge i_clk,negedge i_rstn) begin
	if(~i_rstn) begin
		div_count<=4'h0;
	end else begin
		if (div_count < 4'hf) begin
			div_count<=div_count+1;
		end else begin
			div_count<=4'h0;
		end
	end
end

assign rx_clk = div_count==align_value ;

assign o_clk = rx_clk;

always@(posedge i_clk,negedge i_rstn) begin
        if(~i_rstn) begin
		rx_cdc0<=1'b1;
		rx_cdc1<=1'b1;
        end else begin
		rx_cdc0<=i_rx;
		rx_cdc1<=rx_cdc0;
        end
end

always@(posedge i_clk,negedge i_rstn) begin
        if(~i_rstn) begin
		rx_state<=`ST_START;
		rx_data<=8'h0;
		rx_buff<=8'h0;
		count<=4'h0;
		rx_valid<=1'b0;
		err<=1'b0;
        end else begin
		if (i_en) begin
			case(rx_state) 
			`ST_START: begin
                rx_valid <= 1'b0;
                if (~rx_cdc1) begin
                    rx_state <= `ST_ALIGN;
                    count<= 8'h8;
                    align_count<='b0;
                end 
            end
			`ST_ALIGN:begin 
                if (align_count<7) begin
                    align_count<=align_count+1;
                end else begin
                    rx_state <= `ST_DATA;
                    align_value<=div_count;
                end
            end
			`ST_DATA:begin
                    if (rx_clk) begin
                        if (count >0) begin
                            count<= count-1;
                            rx_buff<= {rx_cdc1, rx_buff[7:1]};
                        end else begin
                            parity <= rx_cdc1;
                            rx_state <= `ST_STOP;
                        end
                    end
            end
			`ST_PARITY: begin
                    if (rx_clk) begin
                        rx_state <= `ST_STOP;
                    end
            end
			`ST_STOP: begin
                    if (rx_clk) begin
                        rx_state <= `ST_START;
                        if (rx_cdc1) begin
                            rx_data<= rx_buff;
                            rx_valid<=1'b1;
                       end else begin
                            err <=1'b1;
                        end
                    end
            end
			default:begin
                rx_state <= `ST_START;
            end
			endcase
		end
        end
end


assign o_rx_data    = rx_data;
assign o_rx_valid   = rx_valid;


endmodule
