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
//Description : ON chip RAM
//
////////////////////////////////////////////////////////////////////


module gpio(
	i_clk,i_rstn,
	i_m2s_wb,o_s2m_wb,
	i_gpio,o_gpio
);

`include "../wishbone/package.vh"

input i_clk;
input i_rstn;
input `WB_M2S i_m2s_wb;
output reg `WB_S2M o_s2m_wb;
input [31:0] i_gpio;
output [31:0] o_gpio;
reg [31:0] mem;
wire [31:0] addr_in;
wire [31:0] data_out;
wire [13:0] addr;
wire [3:0] sel;
wire [1:0] byte_addr;
wire [31:0] data_in;
integer i;
assign addr_in=i_m2s_wb`addr;
assign addr=addr_in[2];
assign byte_addr=addr_in[1:0];
assign sel=i_m2s_wb`sel;
assign data_out=i_m2s_wb`stb & i_m2s_wb`cyc ? mem[addr] :32'h0;
assign data_in = i_m2s_wb`data;
always @(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin	
		mem<='b0;
	end else begin
		if (i_m2s_wb`we & i_m2s_wb`stb & i_m2s_wb`cyc) begin
			if(i_m2s_wb`sel==4'b0001) begin
				if (byte_addr == 2'b00) begin
					mem <={data_out[31:8],data_in[7:0]};
				end else if (byte_addr==2'b01) begin
                    mem <={data_out[31:16],data_in[7:0],data_out[7:0]};
				end else if (byte_addr==2'b10) begin
                    mem <={data_out[31:23],data_in[7:0],data_out[15:0]};
				end else begin
					mem <={data_in[7:0],data_out[23:0]};
				end
			end else if(i_m2s_wb`sel==4'b0011) begin
                if (byte_addr==2'b01) begin
                    mem <={data_out[31:16],data_in[15:0]};
                end else if (byte_addr==2'b11) begin
                    mem <={data_in[15:0],data_out[15:0]};
                end
			end else if (i_m2s_wb`sel==4'b1111) begin
				mem <=data_in;
			end
		end
	end
end



always@(*) begin
	if (sel==4'b1111) begin
		o_s2m_wb`data <= i_gpio;
	end else if (sel==4'b0011) begin
		if (byte_addr==2'b01) begin
			o_s2m_wb`data <={16'h0,i_gpio[15:0]};
		end else begin //if (byte_addr==2'b11) begin
			o_s2m_wb`data <={16'h0,i_gpio[31:16]};
		end
	end else if (sel==4'b0001) begin
		if (byte_addr==2'b00) begin
			o_s2m_wb`data <={24'h0,i_gpio[7:0]};
		end else if (byte_addr==2'b01) begin
			o_s2m_wb`data <={24'h0,i_gpio[15:8]};
		end else if (byte_addr==2'b10) begin
			o_s2m_wb`data <={24'h0,i_gpio[23:16]};
		end else begin
			o_s2m_wb`data <={24'h0,i_gpio[31:24]};
		end
	end else begin
	   o_s2m_wb`data<='b0;
	end
end

always@(i_m2s_wb) o_s2m_wb`ack= i_m2s_wb`stb & i_m2s_wb`cyc? 1'b1 : 1'b0;

assign o_gpio=mem;


endmodule

