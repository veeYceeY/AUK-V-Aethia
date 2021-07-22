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


module oc_ram(
	i_clk,i_rstn,
	i_m2s_wb,o_s2m_wb
)

`include "../wishbone/package.vh" ;

input i_clk;
input i_rstn;
input `WB_M2S i_m2s_wb;
output `WB_S2M o_s2m_wb;

reg [7:0] mem0 [255:0];
reg [7:0] mem1 [255:0];
reg [7:0] mem2 [255:0];
reg [7:0] mem3 [255:0];
wire [31:0] addr_in;
reg [31:0] data_out;
wire [11:0] addr;
wire [3:0] sel;
wire [1:0] byte_addr;
wire [31:0] data_in;
integer i;
assign addr_in=i_m2s_wb`addr;
assign addr= {2'h0,addr_in[11:2]};
assign byte_addr=addr_in[1:0];
assign sel=i_m2s_wb`sel;
//assign data_out=i_m2s_wb`stb & i_m2s_wb`cyc ? mem[addr] :32'h0;
assign data_in = i_m2s_wb`data;
always @(posedge i_clk) begin
	
    if (i_m2s_wb`we & i_m2s_wb`stb & i_m2s_wb`cyc) begin
        if(sel==4'b1111) begin
            mem3[addr+3] <=data_in[31:24];
            mem2[addr+2] <=data_in[23:16];
            mem1[addr+1] <=data_in[15:8];
            mem0[addr+0] <=data_in[7:0];
        end else if(sel==4'b0011) begin
            mem1[addr+1] <=data_in[15:8];
            mem0[addr+0] <=data_in[7:0];
        end else if(sel==4'b0001) begin
            mem0[addr+0] <=data_in[7:0];
        end
    end
end


always@(*) begin
        if (i_m2s_wb`stb & i_m2s_wb`cyc & (~i_m2s_wb`we)) begin
            if(sel==4'b1111) begin
                data_out[7:0] <=mem0[addr+0];
                data_out[15:8] <=mem1[addr+1];
                data_out[23:16] <=mem2[addr+2];
                data_out[31:24] <=mem3[addr+3];
            end else if(sel==4'b0011) begin
                data_out[7:0] <=mem0[addr+0];
                data_out[15:8] <=mem1[addr+1];
                data_out[31:16] <='b0;
            end else if(sel==4'b0001) begin
                data_out[7:0] <=mem0[addr+0];
                data_out[31:8] <='b0;
            end else begin
                data_out[31:0] <='b0;
            end
        end else begin
            data_out[31:0] <='b0;
        end
end
assign o_s2m_wb`data =data_out;


assign o_s2m_wb`ack= i_m2s_wb`stb & i_m2s_wb`cyc? 1'b1 : 1'b0;




//always@(posedge clk or negedge rstn) begin
//    if (~rstn) begin
    
//    end else begin
//        if (data_mem_en & data_mem_we & (data_mem_addr>32'h00100000)) begin
//            if(data_mem_strobe==4'b1111) begin
//                data_mem[data_mem_addr+0 <=data_mem_wdata[31:24];
//                data_mem[data_mem_addr+1 <=data_mem_wdata[23:16];
//                data_mem[data_mem_addr+2 <=data_mem_wdata[15:8];
//                data_mem[data_mem_addr+3 <=data_mem_wdata[7:0];
//            end else if(data_mem_strobe==4'b0011) begin
//                data_mem[data_mem_addr+0 <=data_mem_wdata[15:8];
//                data_mem[data_mem_addr+1 <=data_mem_wdata[7:0];
//            end else if(data_mem_strobe==4'b0001) begin
//                data_mem[data_mem_addr+0 <=data_mem_wdata[7:0];
//            end
//        end
//    end
//end


//always@(*) begin
//    if (~rstn) begin
//        data_mem_rdata<='b0;
//    end else begin
//        if (data_mem_en & (~data_mem_we)) begin
//            if(data_mem_strobe==4'b1111) begin
//                data_mem_rdata[7:0 <=data_mem[data_mem_addr+0];
//                data_mem_rdata[15:8 <=data_mem[data_mem_addr+1];
//                data_mem_rdata[23:16 <=data_mem[data_mem_addr+2];
//                data_mem_rdata[31:24 <=data_mem[data_mem_addr+3];
//            end else if(data_mem_strobe==4'b0011) begin
//                data_mem_rdata[7:0 <=data_mem[data_mem_addr+0];
//                data_mem_rdata[15:8 <=data_mem[data_mem_addr+1];
//                data_mem_rdata[31:16 <='b0;
//            end else if(data_mem_strobe==4'b0001) begin
//                data_mem_rdata[7:0 <=data_mem[data_mem_addr+0];
//                data_mem_rdata[31:8 <='b0;
//            end
//        end
//    end
//end

//always@(*) begin
//    if (~rstn) begin
//        code_mem_rdata<='b0;
//    end else begin
//        if (code_mem_en & (~code_mem_we)) begin
//            code_mem_rdata[7:0 <=code_mem[code_mem_addr+0];
//            code_mem_rdata[15:8 <=code_mem[code_mem_addr+1];
//            code_mem_rdata[23:16 <=code_mem[code_mem_addr+2];
//            code_mem_rdata[31:24 <=code_mem[code_mem_addr+3];
//        end
//    end
//end





endmodule

