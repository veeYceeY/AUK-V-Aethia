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
//Description : Auk-V core top
//
////////////////////////////////////////////////////////////////////

module aukv(
		i_clk,i_rstn,

		i_irq,o_ack,
		
		o_data_mem_en,
		o_data_mem_we,
		o_data_mem_addr,
		o_data_mem_data,
		i_data_mem_valid,
		i_data_mem_data,
		o_data_mem_strobe,

		o_code_mem_en,
		o_code_mem_addr,
		i_code_mem_data,
		i_code_mem_valid
);


input i_clk;
input i_rstn;
input i_irq;
output o_ack;

output o_data_mem_en;
output o_data_mem_we;
output [31:0] o_data_mem_addr;
output [31:0] o_data_mem_data;
output [3:0] o_data_mem_strobe;
input [31:0] i_data_mem_data;

input i_data_mem_valid;

output o_code_mem_en;
output [31:0] o_code_mem_addr;
input [31:0] i_code_mem_data;
input i_code_mem_valid;

reg stall_d1;
reg stall_d2;
reg tmp;

wire ma0_stall;
wire [31:0] wb0_branch_addr;
wire wb0_branch_en;
wire [31:0] fe0_pc;
wire [31:0] fe0_instr;
wire fe0_instr_valid;
wire [4:0] de0_rs1_addr;
wire [4:0] de0_rs2_addr;
wire [4:0] ex0_rs1_addr;
wire [4:0] ex0_rs2_addr;

wire [31:0] rf0_rs1;
wire [31:0] rf0_rs2;

wire [31:0] de0_rs1;
wire [31:0] de0_rs2;
wire [31:0] de0_imm;
wire [31:0] de0_pc;

wire [1:0] de0_op1_sel;
wire [1:0] de0_op2_sel;

wire de0_br_en;
wire [2:0] de0_br_type;
wire de0_br_addr_sel;
wire [3:0] de0_alu_addr_sel;
wire de0_op_sign;
wire [1:0] de0_exe_res_sel;
wire [1:0] de0_mem_store_type;
wire [2:0] de0_mem_load_type;
wire [4:0] de0_wb_reg;
wire [31:0] de0_mem_data;
wire [31:0] ex0_exe_res;
wire [31:0] ex0_br_addr;
wire [31:0] ex0_mem_wr_data;
wire [4:0] ex0_wb_reg_sel;
wire [2:0] ex0_load_type;
wire [1:0] ex0_store_type;
wire [31:0] ma0_br_addr;
wire [31:0] ma0_wb_data;
wire [31:0] ma0_fb_data;
wire [4:0] ma0_wb_reg_del;
wire [31:0] wb0_wb_data;
wire [4:0] wb0_wb_reg_sel;
wire [31:0] wb0_br_addr;

wire [1:0] rs1_fwsel;
wire [1:0] rs2_fwsel;
wire [1:0] de0_rs1_fwsel;
wire [1:0] de0_rs2_fwsel;
wire [31:0] de0_csr_wr_data;
wire [11:0] de0_csr_wr_addr;
wire [11:0] de0_csr_rd_addr;
wire [1:0] de0_csr_op;
wire [31:0] csr0_csr_data;
wire [31:0] ex0_pc;
wire [31:0] ex0_csr_wr_data;
wire [11:0] ex0_csr_wr_addr;
wire [11:0] ex0_csr_rd_addr;
wire [1:0] ex0_csr_op;
wire [31:0] csr0_rd_data;
wire [31:0] cssr0_mtvec;
wire [7:0] exception_id;
wire [7:0] exception_array;
wire [31:0] epc;
wire de0_cmp_op1sel;

wire de0_wb_en;
wire de0_wb_data_sel;
wire de0_mem_en;
wire de0_mem_we;
wire ex0_br_en;
wire ex0_mem_we;
wire ex0_mem_en;
wire ex0_wb_we;
wire ma0_br_en;
wire ma0_wb_we;
wire wb0_wb_we;
wire wb0_br_en;
wire mem_fwsel;
wire de0_mem_fwsel;
wire ex0_mem_fwsel;
wire fetch_stall;
wire de0_stall;
wire de0_instr_valid;
wire [31:0] ex0_mem_addr;
wire ex0_csr_rd;
wire ex0_csr_we;
wire de0_ill_instr;
wire exception;
wire br_flush;
wire de_safe_zone;
wire ex_safe_zone;
wire interrupt;
wire de0_illegal;
wire ex0_illegal;
wire [3:0] de0_alu_opsel;
wire [31:0] csr0_mtvec;
wire [4:0] ma0_wb_reg_sel;
assign fetch_stall= ma0_stall;
assign br_flush= ex0_br_en | interrupt;
assign exception= ex0_illegal | interrupt;

aukv_fetch FE0 (
			.i_clk(i_clk),
			.i_rstn(i_rstn),

			.i_stall(fetch_stall),
			.i_branch_addr(ex0_br_addr),
			.i_evec_addr(csr0_mtvec),
			.i_branch_en(ex0_br_en),
			.i_exception(exception),

			.o_instr_addr_valid(o_code_mem_en),
			.o_instr_addr(o_code_mem_addr),
			.i_instr_data(i_code_mem_data),
			.i_instr_data_valid(i_code_mem_valid),
			.o_pc(fe0_pc),
			.o_instr(fe0_instr),
			.o_instr_valid(fe0_instr_valid)
		);
aukv_decode DEC0(
			.i_clk(i_clk),
			.i_rstn(i_rstn),

			.i_stall(ma0_stall),
			.i_flush(br_flush),

			.i_instr_valid(fe0_instr_valid),
			.i_instr(fe0_instr),
			.i_pc(fe0_pc),

            .o_src1_addr(de0_rs1_addr),
            .o_src2_addr(de0_rs2_addr),
            .i_src1(rf0_rs1),
            .i_src2(rf0_rs2),
            

			.o_rs1(de0_rs1),
			.o_rs2(de0_rs2),

			.o_imm(de0_imm),
			.o_pc(de0_pc),
			.o_instr_valid(de0_instr_valid),
			
			.o_rs1_fwsel(de0_rs1_fwsel),
			.o_rs2_fwsel(de0_rs2_fwsel),
			.o_mem_fwsel(de0_mem_fwsel),

			.o_cmp_op1sel(de0_cmp_op1sel),
			.o_op1_sel(de0_op1_sel),
			.o_op2_sel(de0_op2_sel),

			.o_br_en(de0_br_en),
			.o_br_type(de0_br_type),

			.o_alu_opsel(de0_alu_opsel),
			.o_op_sign(de0_op_sign),
			.o_exe_res_sel(de0_exe_res_sel),

			.o_mem_store_type(de0_mem_store_type),
			.o_mem_load_type(de0_mem_load_type),
			.o_wb_en(de0_wb_en),
			.o_wb_reg(de0_wb_reg),
			.o_wb_data_sel(de0_wb_data_sel),
			.o_mem_en(de0_mem_en),
			.o_mem_we(de0_mem_we),
			.o_mem_data(de0_mem_data),
			.o_stall(de0_stall),

			.o_csr_sel(de0_csr_sel),
			.o_csr_we(de0_csr_we),
			.o_csr_rd(de0_csr_rd),
			.o_csr_wr_addr(de0_csr_wr_addr),
			.o_csr_rd_addr(de0_csr_rd_addr),
			.o_csr_op(de0_csr_op),
			.o_except_ill_instr(de0_illegal)

);

always@(posedge i_clk or negedge i_rstn) begin
	if (~i_rstn) begin
		stall_d1<=1'b0;
		stall_d2<=1'b0;
	end else begin
		stall_d1<=ma0_stall;
		stall_d2<=stall_d1;
	end
end
assign interrupt = ex_dafe_zone &  i_irq;
assign de_safe_zone = ex0_br_en & (~ma0_stall);
assign ex_dafe_zone = ex0_br_en & ex0_instr_valid & (~ma0_stall);

assign o_ack = interrupt;
assign exception_arr = {6'h0,interrupt,ex0_illegal};
assign exception_id = exception_arr;

assign epc=	interrupt ? ex0_pc :
	ex0_illegal ? de0_pc:
	32'h18;

aukv_csr_regfile CSR0(
			.i_clk(i_clk),
			.i_rstn(i_rstn),

			.i_rd_addr(ex0_csr_rd_addr),
			.i_wr_addr(ex0_csr_wr_addr),
			.i_pc(epc),
			.i_instr(fe0_instr),
			.o_mtvec(csr0_mtvec),
			.i_exception_id(exception_id),
			.i_exception(exception),
			.i_data(ex0_csr_wr_data),
			.i_we(ex0_csr_we),
			.i_rd(ex0_csr_rd),
			.i_op(ex0_csr_op),
			.o_data(csr0_rd_data)
);

assign rs1_fwsel = 	de0_rs1_addr != 5'h0 & de0_rs1_addr == ex0_wb_reg_sel & ex0_wb_we & (~tmp)? 2'h1 :
			de0_rs1_addr != 5'h0 & de0_rs1_addr == ex0_wb_reg_sel & ex0_wb_we & (tmp)? 2'h2 :
			de0_rs1_addr != 5'h0 & de0_rs1_addr == ma0_wb_reg_sel & ma0_wb_we ? 2'h2 :2'h0;	

assign rs2_fwsel = 	de0_rs2_addr != 5'h0 & de0_rs2_addr == ex0_wb_reg_sel & ex0_wb_we & (~tmp)? 2'h1 :
			de0_rs2_addr != 5'h0 & de0_rs2_addr == ex0_wb_reg_sel & ex0_wb_we & (tmp)? 2'h2 :
			de0_rs2_addr != 5'h0 & de0_rs2_addr == ma0_wb_reg_sel & ma0_wb_we ? 2'h2 :2'h0;	

assign mem_fwsel = 	ex0_rs2_addr != 5'h0 & ex0_rs2_addr == ma0_wb_reg_sel & ma0_wb_we ;

always@(posedge i_clk or negedge i_rstn) begin
	if(~i_rstn) begin
		tmp<=1'b0;
	end else begin
		tmp<=ma0_stall;
	end
end



aukv_execute EX0(
			.i_clk(i_clk),
			.i_rstn(i_rstn),

			.i_stall(ma0_stall),
			.i_flush(br_flush),
			.i_rs1(de0_rs1),
			.i_rs2(de0_rs2),

			.i_fw_ee(ex0_exe_res),
			.i_fw_me(ma0_fb_data),
			.i_fw_we(32'h0),

			.i_imm(de0_imm),
			.i_pc(de0_pc),
			.o_pc(ex0_pc),
			.i_instr_valid(de0_instr_valid),
			.o_instr_valid(ex0_instr_valid),
			.i_illegal(de0_illegal),
			.o_illegal(ex0_illegal),

			.i_rs1_addr(de0_rs1_addr),
			.i_rs2_addr(de0_rs2_addr),

			.o_rs1_addr(ex0_rs1_addr),
			.o_rs2_addr(ex0_rs2_addr),

			.i_rs1_fwsel(rs1_fwsel),
			.i_rs2_fwsel(rs2_fwsel),
			.i_mem_fwsel(de0_mem_fwsel),

			.i_cmp_op1_sel(de0_cmp_op1sel),
			.i_op1_sel(de0_op1_sel),
			.i_op2_sel(de0_op2_sel),
			.i_signed_op(de0_op_sign),

			.i_alu_sel       (de0_alu_opsel),
            .i_res_sel       (de0_exe_res_sel),
            .i_br_addr_sel   (1'b0),
            .i_br_type_sel   (de0_br_type),
            .i_br_en         (de0_br_en),
            .i_mem_wr_data   (de0_mem_data),
            .i_mem_we        (de0_mem_we),
            .i_mem_en        (de0_mem_en),
            .i_load_type     (de0_mem_load_type),
            .i_store_type    (de0_mem_store_type),
            .i_wb_data_sel   (de0_wb_data_sel),
            .i_wb_reg_sel    (de0_wb_reg),
            .i_wb_we         (de0_wb_en),
            .o_mem_fwsel     (ex0_mem_fwsel),   
            .o_exe_res       (ex0_exe_res),
            .o_br_addr       (ex0_br_addr),
            .o_br_en         (ex0_br_en        ),
            .o_mem_wr_data   (ex0_mem_wr_data  ),
            .o_mem_addr      (ex0_mem_addr     ),
            .o_mem_we        (ex0_mem_we       ),
            .o_mem_en        (ex0_mem_en),
            .o_wb_data_sel   (ex0_wb_data_sel  ),
            .o_wb_reg_sel    (ex0_wb_reg_sel   ),
            .o_wb_we         (ex0_wb_we        ),
            .o_load_type     (ex0_load_type    ),
            .o_store_type    (ex0_store_type   ),
            .i_csr_sel       (de0_csr_sel     ),
            .i_csr_rd        (de0_csr_rd      ),
            .i_csr_we        (de0_csr_we      ),
            .i_csr_wr_addr   (de0_csr_wr_addr ),
            .i_csr_rd_addr   (de0_csr_rd_addr ),
            .i_csr_op        (de0_csr_op      ),
            .o_csr_rd        (ex0_csr_rd      ),
            .o_csr_we        (ex0_csr_we      ),
            .o_csr_wr_data   (ex0_csr_wr_data ),
            .o_csr_wr_addr   (ex0_csr_wr_addr ),
            .o_csr_rd_addr   (ex0_csr_rd_addr ),
            .o_csr_op        (ex0_csr_op      ),
            .i_csr_rd_data   (csr0_rd_data)  
);


aukv_mem MEM0 ( 
           .i_clk               (i_clk),
           .i_rstn               (i_rstn),          
           .i_exe_res           (ex0_exe_res),
           .i_mem_fwsel         (mem_fwsel),
           .i_fw_mm             (ma0_wb_data),
           .i_br_addr           (ex0_br_addr),
           .i_flush             (br_flush),
           .i_mem_wr_data       (ex0_mem_wr_data),
           .i_mem_addr          (ex0_mem_addr),
           .i_mem_we            (ex0_mem_we),
           .i_mem_en            (ex0_mem_en),
           .i_mem_we_p          (de0_mem_we),
           .i_mem_en_p          (de0_mem_en),
           .i_wb_data_sel       (ex0_wb_data_sel),
           .i_wb_reg_sel        (ex0_wb_reg_sel),
           .i_wb_we             (ex0_wb_we),
           .i_load_type         (ex0_load_type),
           .i_store_type        (ex0_store_type),
           .o_data_mem_en       (o_data_mem_en),
           .o_data_mem_we       (o_data_mem_we),
           .o_data_mem_addr     (o_data_mem_addr),
           .o_data_mem_strobe   (o_data_mem_strobe),
           .i_data_mem_data     (i_data_mem_data),
           .i_data_mem_valid    (i_data_mem_valid),
           .o_data_mem_data     (o_data_mem_data),
           .o_stall             (ma0_stall),                   
           .o_br_addr           (ma0_br_addr),
           .o_br_en             (ma0_br_en),
           .o_fb_data           (ma0_fb_data),
           .o_wb_data           (ma0_wb_data),
           .o_wb_reg_sel        (ma0_wb_reg_sel),
           .o_wb_we             (ma0_wb_we)
            
            
  );



aukv_gpr_regfile RF0(
			.i_clk(i_clk),
			.i_rstn(i_rstn),

			.i_rs1_addr(de0_rs1_addr),
			.i_rs2_addr(de0_rs2_addr),

			.i_rd_data(ma0_wb_data),
			.i_rd_addr(ma0_wb_reg_sel),
			.i_we(ma0_wb_we),

			.o_rs1data(rf0_rs1),
			.o_rs2data(rf0_rs2)
);


endmodule
