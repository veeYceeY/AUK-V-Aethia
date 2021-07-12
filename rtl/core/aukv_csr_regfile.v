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
//Description : CSR file 
//
////////////////////////////////////////////////////////////////////


module aukv_csr_regfile (
			i_clk,i_rstn,

			i_exception_id,i_exception,

			i_pc,i_instr,

			i_wr_addr,i_rd_addr,
			i_data,i_we,i_rd,i_op,

			o_mtvec,o_data

			);


input i_clk;
input i_rstn;
input [7:0] i_exception_id;
input i_exception;
input [1:0] i_op;
input [31:0] i_pc;
input [31:0] i_instr;

input [11:0] i_wr_addr;
input [11:0] i_rd_addr;

input [31:0]  i_data;
input i_we;
input i_rd;

output [31:0] o_mtvec;
output [31:0] o_data;
wire exception_lth;
reg exception_d1;
reg [31:0] instr_d1;
reg [31:0] mie;
reg [31:0] mstatus;
reg [31:0] mtval;
reg [31:0] mtvec;
reg [31:0] mepc;
reg [31:0] mcause;


assign exception_lth = (~exception_d1) & i_exception;
assign mcause_tmp=i_exception_id == 8'h1 ? 32'h2 : 32'h0;

assign mtval_tmp = i_exception_id == 8'h1 ? instr_d1 : 32'h0;

always@(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		instr_d1<= 'b0;
	end else begin
		instr_d1<=i_instr;
	end
end

always @(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		exception_d1<= 1'b0;
		mie<=32'h0;
		mstatus<=32'h0;
		mtval<=32'h0;
		mtvec<=32'h0;
		mepc<=32'h0;
		mcause<=32'h0;
	end else begin
		exception_d1<=i_exception;

		if (i_we) begin
			if (i_wr_addr==12'h304) begin
				if (i_op==2'h0) begin
					mie<=mie;
				end else if (i_op==2'h1) begin
					mie<=i_data;
				end else if (i_op==2'h2) begin
					mie<=mie | i_data;
				end else begin
					mie<=mie & (~i_data);
				end
			end else if (i_wr_addr==12'h300) begin
				if (i_op==2'h0) begin
					mstatus<=mstatus;
				end else if (i_op==2'h1) begin
					mstatus<=i_data;
				end else if (i_op==2'h2) begin
					mstatus<=mstatus| i_data;
				end else begin
					mstatus<=mstatus & (~i_data);
				end
			end else if (i_wr_addr==12'h305) begin
				if (i_op==2'h0) begin
					mtvec<=mtvec;
				end else if (i_op==2'h1) begin
					mtvec<=i_data;
				end else if (i_op==2'h2) begin
					mtvec<=mtvec | i_data;
				end else begin
					mtvec<=mtvec & (~i_data);
				end
			end 
		end
		if (exception_lth) begin
			mcause<=mcause_tmp;
			mepc<=i_pc;
			mtval<=mtval_tmp;
		end else begin
			if (i_we) begin
				if (i_wr_addr==12'h343) begin
					if (i_op==2'h0) begin
						mcause<=mcause;
					end else if (i_op==2'h1) begin
						mcause<=i_data;
					end else if (i_op==2'h2) begin
						mcause<=mcause | i_data;
					end else begin
						mcause<=mcause & (~i_data);
					end
				end else if (i_wr_addr==12'h343) begin
                    if (i_op==2'h0) begin
                        mtval<=mtval;
                    end else if (i_op==2'h1) begin
                        mtval<=i_data;
                    end else if (i_op==2'h2) begin
                        mtval<=mtval | i_data;
                    end else begin
                        mtval<=mtval & (~i_data);
                    end
                end
			end
		end


	end 
end



assign o_mtvec= {mtvec[31:2], 2'h0};
assign o_data= i_rd & (i_rd_addr==12'h304) ? mie :
	 i_rd & (i_rd_addr==12'h305) ? mtvec:
	 i_rd & (i_rd_addr==12'h300) ? mstatus:
	 i_rd & (i_rd_addr==12'h341) ? mepc:
	 i_rd & (i_rd_addr==12'h342) ? mcause:
	 i_rd & (i_rd_addr==12'h343) ? mtval:
	 			                 32'h0;

endmodule