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
//Description : Integer register file
//
////////////////////////////////////////////////////////////////////

module aukv_gpr_regfile(i_clk,i_rstn,i_rs1_addr,i_rs2_addr,i_rd_addr,i_we,i_rd_data,o_rs1data,o_rs2data);


input i_clk;
input i_rstn;
input [4:0] i_rs1_addr;
input [4:0] i_rs2_addr;
input [4:0] i_rd_addr;
input [31:0] i_rd_data;
input i_we;
output [31:0] o_rs1data;
output [31:0] o_rs2data;

reg [32-1:0] regfile[31:0];
integer i;
always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        for(i=0;i<32;i=i+1)begin
            regfile[i]<=32'h0;
        end
    end else begin
        if (i_we) begin
            if (i_rd_addr==5'd0) begin
                regfile[i_rd_addr]<=32'h0;
            end else begin
                regfile[i_rd_addr] <= i_rd_data;
            end
        end
    end
end

assign o_rs1data=regfile[i_rs1_addr];
assign o_rs2data=regfile[i_rs2_addr];
endmodule
