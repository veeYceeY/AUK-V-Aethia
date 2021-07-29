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

module baud(
                i_clk,i_rstn,
                i_baud_sel,
                o_clk
            );
            
            
input i_clk;
input i_rstn;
input [31:0] i_baud_sel;
output o_clk;
reg [31:0] count;
reg rst0;
reg rst1;
reg clk;


always@(posedge i_clk,negedge i_rstn) begin
if (~i_rstn) begin
        count<='b0;
        clk<=1'b0;
    end else begin
        if (count < i_baud_sel) begin
            count <= count+1;
            clk<=0;
        end else begin
            count <= 'b0;
            clk <= 1'b1;
        end
    end
end


assign o_clk=clk;


endmodule