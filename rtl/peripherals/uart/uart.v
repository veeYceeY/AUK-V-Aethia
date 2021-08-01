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
//Description : baudrate clock generator
//
////////////////////////////////////////////////////////////////////

module uart (
                i_clk,i_rstn,
                i_wb_m2s,
                o_wb_s2m,
                i_rx,o_tx
);

`include "../wishbone/package.vh"

input i_clk;
input i_rstn;

input  `WB_M2S  i_wb_m2s;
output `WB_S2M  o_wb_s2m;

input i_rx;
output o_tx;

reg tx_drdy;
wire tx_clk;
wire bd0_rst;
wire bd0_txdone;
wire [7:0] txf0_txdata;
wire txf0_tx_empty;
wire [7:0] rx0_rxdata;
wire rx0_rxvalid;
wire bd0_clk;

wire fiforden;
wire fifowren;

wire o_tx_full;
wire [31:0] txdata;
wire i_tx_wren;
wire o_rx_full;
wire o_rx_empty;
wire [7:0] rxdata;
wire i_en;
wire i_parity;
reg [31:0] baud_sel;
wire tx_empty;
reg wren_d1;
reg rden_d1;
reg [31:0] dout;
reg ack;

assign wren= i_wb_m2s`stb & i_wb_m2s`cyc & (i_wb_m2s`we) ;
assign wren_lth= wren & (~ wren_d1);
assign rden= i_wb_m2s`stb & i_wb_m2s`cyc & (~i_wb_m2s`we) ;
assign rden_lth= rden & (~ rden_d1);

//assign addr= i_s_wb`addr;


    
always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        baud_sel<= 32'h0;
    end else begin
        if (wren) begin
            if (i_wb_m2s`addr==32'hc) begin
                baud_sel<= i_wb_m2s`data;
            end
        end
    end
end


assign txdata= i_wb_m2s`data;


     fifo TXF0(
            .i_wrclk (i_clk),
            .i_wrrstn (i_rstn),
            .i_wren  (fifowren),
            .i_wrdata(txdata[7:0]),
            .o_full  (tx_full),
    
            .i_rdclk (tx_clk),
            .i_rdrstn (i_rstn),
            .i_rden  (bd0_txdone),
            .o_rddata(txf0_txdata),
            .o_empty (tx_empty)
        );
        

    assign fifowren =   ~i_rstn ? 1'b0 : wren_lth & i_wb_m2s`addr==0 ? 1'b1 : 1'b0 ;
    assign fiforden =   ~i_rstn ? 1'b0 : rden_lth & i_wb_m2s`addr==4 ? 1'b1 : 1'b0 ;
    
    always@(posedge tx_clk,negedge i_rstn) begin
        if (~i_rstn) begin
            tx_drdy<=1'b0;
        end else begin
            tx_drdy<= ((~tx_empty) & bd0_txdone);
        end
    end
      
    always@(posedge i_clk,negedge i_rstn) begin
        if (~i_rstn) begin
            wren_d1<= 1'b0;
            rden_d1<=1'b0;
        end else begin
            rden_d1<= rden ;
            wren_d1<= wren ;
        end
    end
    
    
    fifo RXF0(
            .i_wrclk (bd0_clk),
            .i_wrrstn (i_rstn),
            .i_wren  (rx0_rxvalid),
            .i_wrdata(rx0_rxdata),
            .o_full  (rx_full),
    
            .i_rdclk (i_clk),
            .i_rdrstn (i_rstn),
            .i_rden  (fiforden),
            .o_rddata(rxdata),
            .o_empty (rx_empty)
        );

uart_tx TX0 ( 
            .i_clk       (bd0_clk),
            .i_rstn       (i_rstn),
            .o_txclk  (tx_clk),
            
            .i_en        (1'b1),
            .o_done      (bd0_txdone),
            .i_parity    (1'b0),
            .i_txdata    (txf0_txdata),
            .i_txen      (tx_drdy),

            .o_tx        (o_tx)
    );


uart_rx RX0 (
            .i_clk       (bd0_clk),
            .i_rstn       (i_rstn),
            
            .i_en        (1'b1),
            
            .o_clk  (rx_clk),

            .o_rx_data    (rx0_rxdata),
            .o_rx_valid   (rx0_rxvalid),

            .i_rx        (i_rx)
    );


baud BD0  (
            .i_clk       (i_clk),
            .i_rstn       (i_rstn),

            .i_baud_sel  (baud_sel),

            .o_clk       (bd0_clk)
            
    );



always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        ack<= 1'b0;
        dout<='b0;
    end else begin
        dout<= {24'b0,rxdata};
        ack<= wren_lth | rden_lth;
    end
end

assign o_wb_s2m`data =  (i_wb_m2s`addr == 4) ? dout :
                         i_wb_m2s`addr == 8 ? {28'b0, tx_full , tx_empty , rx_full , rx_empty} :
                         i_wb_m2s`addr == 12 ? 'b0 :'b0;
assign o_wb_s2m`ack = ack;
endmodule