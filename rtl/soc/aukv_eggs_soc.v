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
//Description : Mini soc built arround auk-v
//
////////////////////////////////////////////////////////////////////


module aukv_eggs_soc(
	i_clk,i_rstn,
	i_rx,o_tx,
	o_led,i_switch
);


`include "package.vh"


input i_clk;
input i_rstn;
input i_rx;
output o_tx;
//input [31:0] i_gpio;
output [2:0] o_led;
input [4:0] i_switch;
wire [31:0] cache0_code_mem_data;
wire cache0_code_mem_valid;
wire [31:0] cache0_code_mem_address;
wire cache0_code_mem_en;


wire [3:0] core0_data_mem_strobe;
wire [31:0] core0_data_mem_data;
wire [31:0] core0_data_mem_addr;
wire core0_data_mem_en;
wire core0_data_mem_we;

wire core0_code_mem_en;
wire [31:0] core0_code_mem_addr;

wire [31:0] gpio0_data;

wire [31:0] master0_code_mem_data;
wire  master0_code_mem_valid;

wire [31:0] master1_data_mem_data;
wire  master1_data_mem_valid;

wire plic0_irq;
wire core0_ack;

wire `WB_M2S master0_noc0_m2s_wb;
wire `WB_S2M noc0_master0_s2m_wb;
wire `WB_M2S master1_noc0_m2s_wb;
wire `WB_S2M noc0_master1_s2m_wb;
wire `WB_M2S noc0_rom0_m2s0_wb;
wire `WB_S2M rom0_noc0_s2m0_wb;
wire `WB_M2S noc0_ram0_m2s0_wb;
wire `WB_S2M ram0_noc0_s2m0_wb;
wire `WB_M2S noc0_gpio0_m2s0_wb;
wire `WB_S2M gpio0_noc0_s2m0_wb;


wire `WB_M2S noc0_ram1_m2s0_wb;
wire `WB_S2M ram1_noc0_s2m0_wb;

wire `WB_M2S noc0_uart0_m2s0_wb;
wire `WB_S2M uart0_noc0_s2m0_wb;

wire [31:0] gpio_in ;

assign gpio_in = {27'h0,i_switch};

reste_sync  RSYNC0( 
       .i_clk(i_clk),
       .i_rstn(i_rstn),
       .o_rstn(rsyn0_rstn)
    );


aukv CORE0(
.i_clk(i_clk),
    .i_rstn(rsyn0_rstn),
    .i_irq(plic0_irq),
    .o_ack(core0_ack),
    .o_data_mem_en(core0_data_mem_en),
    .o_data_mem_we(core0_data_mem_we),
    .o_data_mem_addr(core0_data_mem_addr),
    .o_data_mem_data(core0_data_mem_data),
    .i_data_mem_valid(master1_data_mem_valid),
    .i_data_mem_data(master1_data_mem_data),
    .o_data_mem_strobe(core0_data_mem_strobe),
    .o_code_mem_en(core0_code_mem_en),
    .o_code_mem_addr(core0_code_mem_addr),
    .i_code_mem_data(cache0_code_mem_data),
    .i_code_mem_valid(cache0_code_mem_valid)
);


cache CACHE0(
        .i_clk (i_clk),
        .i_rstn (rsyn0_rstn),
        .i_req (core0_code_mem_en),
        .i_addr (core0_code_mem_addr),
        .o_data (cache0_code_mem_data),
        .o_ack  (cache0_code_mem_valid),
        .o_req  (cache0_code_mem_en),
        .o_addr (cache0_code_mem_address),
        .i_data (master0_code_mem_data),
        .i_ack  (master0_code_mem_valid)
        
);

//cacheo CACHE0(
//        .i_clk (i_clk),
//        .i_rst (~rsyn0_rstn),
//        .i_req (core0_code_mem_en),
//        .i_addr (core0_code_mem_addr),
//        .o_data (cache0_code_mem_data),
//        .o_ack  (cache0_code_mem_valid),
//        .o_req  (cache0_code_mem_en),
//        .o_addr (cache0_code_mem_address),
//        .i_data (master0_code_mem_data),
//        .i_ack  (master0_code_mem_valid)
        
//);

wb_master MASTER0(
		.i_clk(i_clk),
		.i_rstn(rsyn0_rstn),
		.i_en(cache0_code_mem_en),
		.i_we(1'b0),
		.i_addr(cache0_code_mem_address),
		.i_data(32'h0),
		.i_strobe(4'b1111),
		.o_valid(master0_code_mem_valid),
		.o_data(master0_code_mem_data),
		
		.i_wb(noc0_master0_s2m_wb),
		.o_wb(master0_noc0_m2s_wb)
);

wb_master MASTER1(
		.i_clk(i_clk),
		.i_rstn(rsyn0_rstn),
		.i_en(core0_data_mem_en),
		.i_we(core0_data_mem_we),
		.i_addr(core0_data_mem_addr),
		.i_data(core0_data_mem_data),
		.i_strobe(core0_data_mem_strobe),
		.o_valid(master1_data_mem_valid),
		.o_data(master1_data_mem_data),
		
		.i_wb(noc0_master1_s2m_wb),
		.o_wb(master1_noc0_m2s_wb)
);

wb_interconnect NOC0( 
	.i_clk(i_clk),
	.i_rstn(rsyn0_rstn),
	
	.i_m2s0_wb(master0_noc0_m2s_wb),
	.o_s2m0_wb(noc0_master0_s2m_wb),
	.i_m2s1_wb(master1_noc0_m2s_wb),
	.o_s2m1_wb(noc0_master1_s2m_wb),
	
	.o_m2s0_wb(noc0_rom0_m2s0_wb),
	.i_s2m0_wb(rom0_noc0_s2m0_wb),
	.o_m2s1_wb(noc0_gpio0_m2s0_wb),
	.i_s2m1_wb(gpio0_noc0_s2m0_wb),
	.o_m2s2_wb(),
	.i_s2m2_wb('b0),
	.o_m2s3_wb(noc0_uart0_m2s0_wb),
	.i_s2m3_wb(uart0_noc0_s2m0_wb),
	.o_m2s4_wb(),
	.i_s2m4_wb('b0),
	.o_m2s5_wb(noc0_ram0_m2s0_wb),
	.i_s2m5_wb(ram0_noc0_s2m0_wb)
);

oc_rom ROM0(
	.i_clk(i_clk),
	.i_rstn(rsyn0_rstn),
	.i_m2s_wb(noc0_rom0_m2s0_wb),
	.o_s2m_wb(rom0_noc0_s2m0_wb)
);

oc_ram RAM0(
	.i_clk(i_clk),
	.i_rstn(rsyn0_rstn),
	.i_m2s_wb(noc0_ram0_m2s0_wb),
	.o_s2m_wb(ram0_noc0_s2m0_wb)
);

//oc_ram RAM1(
//	.i_clk(i_clk),
//	.i_rstn(rsyn0_rstn),
//	.i_m2s_wb(noc0_ram1_m2s0_wb),
//	.o_s2m_wb(ram1_noc0_s2m0_wb)
//);


gpio GPIO0(
	.i_clk(i_clk),
	.i_rstn(rsyn0_rstn),
	.i_m2s_wb(noc0_gpio0_m2s0_wb),
	.o_s2m_wb(gpio0_noc0_s2m0_wb),
	.o_gpio(gpio0_data),
	.i_gpio(gpio_in)
);
uart UART0(
                .i_clk(i_clk),
                .i_rstn(rsyn0_rstn),
                .i_wb_m2s(noc0_uart0_m2s0_wb),
                .o_wb_s2m(uart0_noc0_s2m0_wb),
                .i_rx(i_rx),
                .o_tx(o_tx)
);

assign plic0_irq=1'b0;


assign o_led=gpio0_data[2:0];


endmodule