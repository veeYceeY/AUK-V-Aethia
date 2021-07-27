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
`define ST_IDLE 2'h0
`define ST_LOAD 2'h1
`define ST_WAIT 2'h2

//`define tag_in addr_in[31-(OFFSET+2) : 0]
//`define set_in addr_in[OFFSET-1 : OFFSET]
//`define offset_in addr_in[OFFSSET-1:2]
//`define tag_wr addr[31 : OFFSET+2]
//`define set_wr addr[OFFSET+1 : OFFSET]

module cache(
	i_clk,i_rstn,
	i_req,i_addr,
	o_ack,o_data,

	o_req,o_addr,
	i_ack,i_data
);

parameter LINE_SIZE = 16;
parameter OFFSET = 6;

input i_clk;
input i_rstn;
input i_req;
input [31:0] i_addr;
output o_ack;
output [31:0] o_data;
output o_req;
output [31:0] o_addr;
input i_ack;
input [31:0] i_data;

wire [31-(OFFSET+2) : 0] tag_in ;
wire [1:0] set_in;
wire [OFFSET-1-2:0] offset_in;
wire [31-(OFFSET+2) : 0]  tag_wr;
wire [1:0] set_wr;

reg [31:0] line0 [LINE_SIZE-1 :0];
reg [31:0] line1 [LINE_SIZE-1 :0];
reg [31:0] line2 [LINE_SIZE-1 :0];
reg [31:0] line3 [LINE_SIZE-1 :0];

reg [3:0] valid;

reg [31-(OFFSET+2) : 0 ] tag [3:0];

reg req;
wire load;
wire hit ;
reg req_in;
reg ack;
wire [31:0] line_selected [LINE_SIZE-1 :0]; 
wire valid_selected;
wire [31-(OFFSET+2) : 0 ] tag_selected;
reg [31:0] addr;
reg [31:0] addr_in;
reg [31:0] count;
reg [1:0] state;
wire [31:0] data;
//alias tag_in is addr_in(31 downto OFFSET+2);
//alias set_in is addr_in(OFFSET+1 downto OFFSET);
//alias offset_in is addr_in(OFFSET-1 downto 2);
//alias tag_wr is addr(31 downto OFFSET+2);
//alias set_wr is addr(OFFSET+1 downto OFFSET);

assign tag_in=addr_in[31:(OFFSET+2)];
assign set_in= addr_in[OFFSET+1 : OFFSET];
assign offset_in= addr_in[OFFSET-1:2];
assign tag_wr= addr[31 : OFFSET+2];
assign set_wr= addr[OFFSET+1 : OFFSET];

assign data = set_in == 2'b00 ? line0[offset_in] :
                       set_in == 2'b01 ? line1[offset_in] :
		       set_in == 2'b10 ? line2[offset_in] : line3[offset_in];
assign valid_selected = set_in == 2'b00 ? valid[0]:
                       set_in == 2'b01 ? valid[1] :
                       set_in == 2'b10 ? valid[2] : valid[3];
assign tag_selected = set_in == 2'b00 ? tag[0] :
                       set_in == 2'b01 ? tag[1] :
                       set_in == 2'b10 ? tag[2] : tag[3];

assign tag_match = tag_selected==tag_in?1'b1 : 1'b0;
assign hit = tag_match & valid_selected;
//assign data = line_selected[offset_in];

assign load = (~hit) & req_in;
assign o_data = (hit & (req_in | ack)) ? data : 'b0;
assign o_ack = (hit & (req_in | ack));
assign o_req = req;
assign o_addr = addr;

always@(posedge i_clk,negedge i_rstn) begin
	if (~i_rstn) begin
		addr_in <='b0;
		req_in <= 'b0;
	end else begin
		if(i_req) begin
			addr_in <= i_addr;
		end
		req_in<=i_req;
	end

end

always@(posedge i_clk,negedge i_rstn) begin
	if(~i_rstn) begin
		state<= `ST_IDLE;
		ack<=1'b0;
		req<=1'b0;
		count<='b0;
		addr<='b0;
	end else begin
		if (i_req) begin
			state<=`ST_IDLE;
		end else begin
			case(state)
				`ST_IDLE : begin
					ack<=1'b0;
					if(load) begin
						state<=`ST_LOAD;
						addr<={addr_in[31: OFFSET],6'b0};
						count<='b0;
					end
				end
				`ST_LOAD : begin
					if(count<LINE_SIZE) begin
						count<=count+1;
						state<=`ST_WAIT;
						req<=1'b1;
					end else begin
						req<=1'b0;
						state<=`ST_IDLE;
						ack<=1'b1;
					end
				end
				`ST_WAIT : begin
					req<=1'b0;
					if(i_ack) begin
						addr<=addr+4;
						state<=`ST_LOAD;
					end
				end
				default: begin
				    state<=`ST_IDLE;
				end
			endcase
		end
			       		       

	end
end

always@(posedge i_clk,negedge i_rstn) begin
	if(~i_rstn) begin
		valid<='b0;
	end else begin
		if(i_ack) begin
			if (count==15) begin
				valid[set_in]<=1'b1;
				tag[set_wr]<=tag_wr;
			end 
		end
	end

end

always@(posedge i_clk) begin
    if(i_ack) begin
        if (set_wr==0) begin
            line0[addr[OFFSET-1:2]]<=i_data;
        end else if (set_wr==1) begin
            line1[addr[OFFSET-1:2]]<=i_data;
        end else if (set_wr==2) begin
            line2[addr[OFFSET-1:2]]<=i_data;
        end else begin
            line3[addr[OFFSET-1:2]]<=i_data;
        end
    end
end

endmodule
