
`define ST_IDLE 2'b00
`define ST_M0_ACTIVE 2'b01
`define ST_M1_ACTIVE 2'b10 


module wb_arbiter(i_clk,i_rstn,
	i_m2s0_wb,o_s2m0_wb,
	i_m2s1_wb,o_s2m1_wb,
	i_s2m_wb,o_m2s_wb
);
 

`include "package.vh" ;

input i_clk;
input i_rstn;
input `WB_M2S i_m2s0_wb;
input `WB_M2S i_m2s1_wb;
output `WB_M2S o_m2s_wb;
input `WB_S2M i_s2m_wb;
output `WB_S2M o_s2m0_wb;
output `WB_S2M o_s2m1_wb;

reg [1:0] state;



always @(posedge i_clk,negedge i_rstn) begin
	if(~i_rstn) begin
		state<=`ST_IDLE;
	end else begin
		case(state) 
		`ST_IDLE:
			if (i_m2s1_wb`cyc) begin
				state<=`ST_M1_ACTIVE;
			end else begin
				if(i_m2s0_wb`cyc) begin
					state<=`ST_M0_ACTIVE;
				end
			end
		`ST_M0_ACTIVE:
			if (i_m2s0_wb`cyc) begin
				state<=`ST_IDLE;
			end
		`ST_M1_ACTIVE:
			if (i_m2s0_wb`cyc) begin
				state<=`ST_IDLE;
			end
		default:
			state<=`ST_IDLE;
		endcase
	end

end


assign o_s2m0_wb= state==`ST_M0_ACTIVE ? i_s2m_wb : 'h0;
assign o_s2m1_wb= state==`ST_M1_ACTIVE ? i_s2m_wb : 'h0;

assign o_m2s_wb= state== `ST_M1_ACTIVE ? i_m2s1_wb : 
	 state== `ST_M0_ACTIVE ? i_m2s0_wb : 'h0;

endmodule