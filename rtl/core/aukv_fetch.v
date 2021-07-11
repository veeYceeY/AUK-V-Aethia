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
//Description : Fetch unit
//
////////////////////////////////////////////////////////////////////
 
module aukv_fetch 
        ( i_clk,i_rstn,
        i_instr_data,i_instr_data_valid,o_instr_addr,o_instr_addr_valid,
        i_stall,i_branch_addr,i_evec_addr,i_branch_en,i_exception,
        o_pc,o_instr,o_instr_valid
        );


input i_clk;
input i_rstn;
input [31:0] i_instr_data;
input i_instr_data_valid;
output o_instr_addr_valid;
output [31:0] o_instr_addr;
input i_stall;
input [31:0] i_branch_addr;
input [31:0] i_evec_addr;
input i_branch_en;
input i_exception;

output [31:0] o_pc;
output [31:0] o_instr;
output o_instr_valid;

reg [31:0] pc;
reg en_buff;
reg branch_lat;
reg [31:0] data_buff;
reg start;
//reg flush;
wire en_stall;
wire branch_buff;
wire en;
wire ins_valid;
wire [31:0] t_pc;
wire branch;
assign branch=i_branch_en | i_exception;
always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        start<=1'b1;
    end else begin
        start<=1'b0;
    end
end
always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        branch_lat<=1'b0;
    end else begin
        if (branch_buff) begin
            if (branch_lat) begin
                branch_lat<=1'b1;
            end
        end else begin
            if (i_instr_data_valid) begin
                branch_lat<=1'b0;
            end
        end
    end
end


always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        en_buff<=1'b0;
        data_buff<=32'h33;
    end else begin
        if (~en_buff) begin
            if (i_stall & i_instr_data_valid) begin
                en_buff<=1'b1;
                data_buff<=i_instr_data;
            end
        end else begin
            if (i_stall) begin
                en_buff<=1'b0;
            end
        end
    end
end



always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        pc<=32'h33;
    end else begin
        if (i_stall) begin
            if (i_exception) begin
                pc<=i_evec_addr;
            end
        end else begin
            if (i_branch_en) begin
                //flush<=1'b1;
                pc<= i_branch_addr + 32'h4;
            end else begin
                if (en) begin
                    pc<=pc+4;
                end
            end
        end
    end
end

assign en_stall=en_buff & (~ i_stall);
assign branch_buff=branch_lat & i_instr_data_valid;
assign en=i_rstn & (i_instr_data_valid | start | en_buff | branch) & (~i_stall);
assign ins_valid = (i_instr_data_valid & (~branch) & (~branch_buff)  & (~i_stall)) & (~start);
assign t_pc = i_exception? i_evec_addr : i_branch_en? i_branch_addr : pc;
assign o_instr_addr=t_pc;
assign o_pc = t_pc+4;
assign o_instr=en_stall ? data_buff: ins_valid ? i_instr_data : 32'h33;
assign o_instr_valid = ins_valid;
assign o_instr_addr_valid= en;
endmodule
