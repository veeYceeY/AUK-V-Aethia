
`define ST_IDLE 2'b00
`define ST_WR_ACK_WAIT 2'b01
`define ST_RD_ACK_WAIT 2'b10

module wb_master(
		i_clk,i_rstn,
		i_en,i_we,
		i_addr,i_data,
		i_strobe,
		o_valid,o_data,
		
		i_wb,
		o_wb,
);

`include "package.vh"


input i_clk;
input i_rstn;
input i_en;
input i_we;
input [31:0] i_addr;
input [31:0] i_data;
input [3:0] i_strobe;

output o_valid;
output reg [31:0] o_data;

input `WB_S2M i_wb;
output reg `WB_M2S o_wb;


reg state;
reg r_ack;


always@(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		o_wb`addr<='h0;
		o_wb`data<='h0;
		o_wb`sel<='h0;
		o_wb`cyc<='b0;
		o_wb`stb<='b0;
		o_wb`we<='b0;
	end else begin
		case(state) 
		`ST_IDLE: begin
			if (i_en & i_we) begin
					o_wb`addr <=i_addr;
					o_wb`data <=i_data;
					o_wb`sel <=i_strobe;
					o_wb`cyc <=1'b1;
					o_wb`stb <=1'b1;
					o_wb`we <=1'b1;
					state<=`ST_WR_ACK_WAIT;
			end else begin
				if (i_en & (~i_we)) begin
					o_wb`addr <=i_addr;
					o_wb`data <=i_data;
					o_wb`sel <=i_strobe;
					o_wb`cyc <=1'b1;
					o_wb`stb <=1'b1;
					o_wb`we <=1'b0;
					state<=`ST_RD_ACK_WAIT;
				end
			end
			r_ack<='b0;
		end
		`ST_RD_ACK_WAIT: begin
			if (i_wb`ack) begin
				o_data<=i_wb`data;
				o_wb`cyc <=1'b0;
				o_wb`stb <=1'b0;
				r_ack<=1'b1;
				state<=`ST_IDLE;
			end
		end
		`ST_WR_ACK_WAIT: begin
			if (i_wb`ack) begin
				o_data<=i_wb`data;
				o_wb`cyc <=1'b0;
				o_wb`stb <=1'b0;
				r_ack<=1'b1;
				state<=`ST_IDLE;
			end
		end
		default:
			state<=`ST_IDLE;
		endcase
	end
end

assign o_valid=r_ack;


endmodule
