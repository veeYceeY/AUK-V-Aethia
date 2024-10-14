module aukv_eggs_soc_tb();
	
	reg clk;
	reg rstn;
	wire [2:0] led;
	wire [4:0] switch;
	wire tx;
	wire rx;
	assign rx=1'b0;
	
assign switch = 5'h5;
	
always
begin
    clk<=1'b0;
    #10;
    clk<=1'b1;
    #10;
end

always
begin
    rstn<=1'b0;
    #500;
    rstn<=1'b1;
    #100000000000;
    $stop;
end
	
aukv_eggs_soc DUT0(
	.i_clk(clk),
	.i_rstn(rstn),
	.i_rx(tx),
	.o_tx(tx),
	.o_led(led),
	.i_switch(switch)
);
	
	
endmodule
