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
//Description : Memory Access
//
////////////////////////////////////////////////////////////////////
 
module aukv_mem (
            i_clk,i_rstn,
            i_exe_res,
            i_br_addr,
            i_flush,
            i_mem_fwsel,i_fw_mm,
            i_mem_wr_data,i_mem_addr,i_mem_we,i_mem_en,
            i_mem_we_p,i_mem_en_p,
            i_wb_data_sel,
            i_wb_reg_sel,
            i_wb_we,
            i_load_type,i_store_type,
            o_data_mem_en,o_data_mem_we,
            o_data_mem_data,o_data_mem_addr,o_data_mem_strobe,
            i_data_mem_data,i_data_mem_valid,

            o_stall,
            o_br_addr,o_br_en,
            o_fb_data,
            o_wb_data,o_wb_reg_sel,o_wb_we
);

input i_clk ;
input i_rstn;
input [31:0] i_exe_res;
input [31:0] i_br_addr;
input i_flush;
input i_mem_fwsel;
input [31:0] i_fw_mm;
input [31:0] i_mem_addr;
input [31:0] i_data_mem_data;
output [31:0] o_data_mem_data;
output [31:0] o_data_mem_addr;
output reg [31:0] o_br_addr;
output reg [31:0] o_fb_data;
output reg [31:0] o_wb_data;
output reg [4:0] o_wb_reg_sel;
input [31:0] i_mem_wr_data;
output o_data_mem_en;
output o_data_mem_we;
output o_stall;
output reg o_br_en;
output reg o_wb_we;
input i_mem_we;
input i_mem_en;
input i_mem_we_p;
input i_mem_en_p;
input i_wb_data_sel;
input i_wb_we;
input i_data_mem_valid;

input [4:0] i_wb_reg_sel;
input [2:0] i_load_type;
input [1:0] i_store_type;
output [3:0] o_data_mem_strobe;

wire [31:0] mem_data_rd_sb;
wire [31:0] mem_data_rd_sh;
wire [31:0] mem_data_rd_sw;

wire [31:0] mem_data_rd_ub;
wire [31:0] mem_data_rd_uh;

wire stall_t;
reg stall;
reg stall_d0;
reg stall_state;

wire [31:0] mem_data_rd;
wire [31:0] mem_data_wr;
wire [3:0] mem_strobe_wr;
wire [3:0] mem_strobe_rd;
wire [31:0] wb_data;
wire [3:0] mem_strobe;
reg valid_d1;



assign mem_data_rd_sb = {{24{i_data_mem_data[7]}},i_data_mem_data};
assign mem_data_rd_sh = {{16{i_data_mem_data[15]}},i_data_mem_data};
assign mem_data_rd_sw = i_data_mem_data;

assign  mem_data_rd_ub = {{24{1'b0}},i_data_mem_data[7:0]};
assign  mem_data_rd_uh = {{16{1'b0}},i_data_mem_data[15:0]};


assign mem_data_rd =  i_load_type ==3'b000 ? mem_data_rd_sb : 
                i_load_type ==3'b001 ? mem_data_rd_sh : 
                i_load_type ==3'b010 ? mem_data_rd_sw : 
                i_load_type ==3'b011 ? mem_data_rd_ub : 
                i_load_type ==3'b100 ? mem_data_rd_uh : 
                mem_data_rd_sw;

assign mem_data_wr = i_mem_fwsel ? i_fw_mm : i_mem_wr_data;

assign mem_strobe_wr = i_store_type == 2'h0 ? 4'h1 :
	               i_store_type ==2'h1 ? 4'h3 :
		       i_store_type == 2'h2 ? 4'hf :
		                             4'h0 ;

assign mem_strobe_rd = i_load_type == 3'h0 ? 4'h1 :
	               i_load_type == 3'h1 ? 4'h3 :
		       i_load_type == 3'h2 ? 4'hf :
		       i_load_type == 3'h3 ? 4'h1 :
		       i_load_type == 3'h4 ? 4'h3 :
		                            4'h0 ;



assign wb_data = ~i_wb_data_sel ? i_exe_res : mem_data_rd;

assign mem_strobe = ~i_mem_we ? mem_strobe_rd : mem_strobe_wr ;

always@(posedge i_clk or negedge i_rstn) begin
  if(~i_rstn) begin
    valid_d1 <= 1'b0;
  end else begin
    valid_d1 <= i_data_mem_valid;
  end
end

always @(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		stall<=1'b0;
		stall_state<=1'b0;
	end else begin
		if (~stall_state) begin
			if (i_mem_en_p & (~i_flush)) begin
				stall_state<='b1;
				stall<=1'b1;
			end else begin
				stall<=1'b0;
			end
		end else begin
			if (i_data_mem_valid) begin
				stall_state<=1'b0;
				stall<=1'b0;
			end else begin
				stall<= 1'b1;
			end
		end
	end
end
assign stall_t = stall & (~i_data_mem_valid);

always @(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		stall_d0 <= 1'b0;
	end else begin
		stall_d0<= stall;
	end 
end


always @(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		o_br_addr<=32'h0;
		o_br_en<=1'b0;
		o_wb_data<=32'h0;
		o_wb_reg_sel <= 5'h0;
		o_wb_we<=1'b0;
	end else begin
		if (~stall_t) begin
			o_fb_data<= wb_data;
			o_br_addr<=i_br_addr;
			o_br_en<=i_flush;
			o_wb_data<=wb_data;
			o_wb_reg_sel<= i_wb_reg_sel;
			o_wb_we<=i_wb_we;
		end
	end
end

assign o_stall= stall;
assign o_data_mem_en= i_mem_en & (~stall_d0);
assign o_data_mem_we=i_mem_we & (~stall_d0);
assign o_data_mem_addr=i_mem_addr;
assign o_data_mem_strobe=mem_strobe;
assign o_data_mem_data= mem_data_wr;




endmodule
