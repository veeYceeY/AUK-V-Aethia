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
//Description : wishbone mux switch
//
////////////////////////////////////////////////////////////////////


module reste_sync( 
	               i_clk,
	               i_rstn,
	               o_rstn
                );
                
input i_clk;
input i_rstn;
output o_rstn;
reg rstn0;
reg rstn1;

always@(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        rstn0<=1'b0;
        rstn1<=1'b0;
    end else begin
        rstn0<=1'b1;
        rstn1<=rstn0;
    end
end
assign o_rstn = rstn1;
endmodule