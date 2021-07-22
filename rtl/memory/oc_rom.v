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
//Description : ON chip ROM
//
////////////////////////////////////////////////////////////////////


module oc_rom(
	i_clk,i_rstn,
	i_m2s_wb,o_s2m_wb
)

`include "../wishbone/package.vh" ;

input i_clk;
input i_rstn;
input `WB_M2S i_m2s_wb;
output `WB_S2M o_s2m_wb;

reg [7:0] mem [4095:0];
wire [31:0] addr_in;
reg [31:0] data_out;
wire [11:0] addr;
wire [3:0] sel;
wire [1:0] byte_addr;
wire [31:0] data_in;
assign addr_in=i_m2s_wb`addr;
assign addr={addr_in[11:0]};
assign byte_addr=addr_in[1:0];
assign sel=i_m2s_wb`sel;
//assign data_out= mem[addr];//i_m2s_wb`stb & i_m2s_wb`cyc ? mem[addr] :32'h0;
assign data_in = i_m2s_wb`data;


initial $readmemh("main.mem",mem);


always@(*) begin
        if (i_m2s_wb`stb & i_m2s_wb`cyc & (~i_m2s_wb`we)) begin
            if(sel==4'b1111) begin
                data_out[7:0] <=mem[addr+0];
                data_out[15:8] <=mem[addr+1];
                data_out[23:16] <=mem[addr+2];
                data_out[31:24] <=mem[addr+3];
            end else if(sel==4'b0011) begin
                data_out[7:0] <=mem[addr+0];
                data_out[15:8] <=mem[addr+1];
                data_out[31:16] <='b0;
            end else if(sel==4'b0001) begin
                data_out[7:0] <=mem[addr+0];
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

endmodule

