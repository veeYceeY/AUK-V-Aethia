 
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
//Description : fifo
//
////////////////////////////////////////////////////////////////////

`define T_ADDRESS [$clog2(P_DEPTH) : 0]
`define T_DATA [P_WIDTH-1:0]
`define T_DEPTH [P_DEPTH-1:0]
`define overflow [$clog2(P_DEPTH)]
`define address [$clog2(P_DEPTH)-1:0]


module fifo (
                        i_wrclk,i_wrrstn,
                        i_wren,i_wrdata,
                        o_full,
                        i_rdclk,i_rdrstn,
                        i_rden,o_rddata,
                        o_empty
);

parameter P_DEPTH = 64;
parameter P_WIDTH = 8;


input i_wrclk;
input i_wrrstn;
input i_wren;
input `T_DATA i_wrdata;
output o_full;
input i_rdclk;
input i_rdrstn;
input i_rden;
output `T_DATA o_rddata;
output o_empty;

reg `T_DATA mem `T_DEPTH;
reg `T_ADDRESS rd_addr;
reg `T_ADDRESS wr_addr;
//reg `T_ADDRESS ac_rd_addr;
//reg `T_ADDRESS ac_wr_addr;
//reg `T_ADDRESS sync_rd_addr;
//reg `T_ADDRESS sync_wr_addr;

//reg `T_ADDRESS grey_rd_addr;
//reg `T_ADDRESS grey_wr_addr;
//reg `T_ADDRESS grey_rd_addr1;
//reg `T_ADDRESS grey_wr_addr1;
//reg `T_ADDRESS grey_rd_addr2;
//reg `T_ADDRESS grey_wr_addr3;


wire full ;
wire empty;
reg `T_DATA rd_data;

assign full = ((wr_addr`overflow != rd_addr`overflow) &(rd_addr`address != wr_addr`address));
assign empty = (rd_addr == wr_addr);

always@(posedge i_wrclk,negedge i_wrrstn) begin
        if (~i_wrrstn) begin
            wr_addr<= 'b0;
        end else begin
            if (i_wren) begin
                if (~full)  begin
                    wr_addr <= wr_addr+1;
                end
            end
        end
end


always@(posedge i_rdclk,negedge i_rdrstn) begin
        if (~i_rdrstn) begin
            rd_addr<= 'b0;
        end else begin
            if (i_rden) begin
                if (~empty)  begin
                    rd_addr <= rd_addr+1;
                end
            end
        end
end

always@(posedge i_wrclk) begin
    if (i_wren) begin
        mem[wr_addr`address]<= i_wrdata;
    end
end

always@(posedge i_rdclk,negedge i_rdrstn) begin
    if (~i_rdrstn) begin
        rd_data<= 'b0;
    end else begin
        if (i_rden) begin
            rd_data <=mem[rd_addr`address];
        end
    end
end


assign o_full = full;
assign o_empty = empty;
assign o_rddata = rd_data;


endmodule
