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
//Description : Instruction decoder with data forwarding logic
//
////////////////////////////////////////////////////////////////////
 
 
module aukv_decode(
                    i_clk,i_rstn,
                    i_stall,i_flush,
                    i_instr_valid,i_instr,i_pc,
                    
                    o_src1_addr,o_src2_addr,
                    i_src1,i_src2,
                    
                    o_rs1,o_rs2,o_imm,o_pc,o_instr_valid,

                    o_rs1_fwsel,o_rs2_fwsel,o_mem_fwsel,

                    o_cmp_op1sel,o_op1_sel,o_op2_sel,

                    o_br_en,o_br_type,

                    o_alu_opsel,o_op_sign,o_exe_res_sel,
                    o_mem_store_type,o_mem_load_type,o_mem_en,o_mem_we,o_mem_data,
                    
                    o_wb_en,o_wb_reg,o_wb_data_sel,
               
                    o_stall,o_except_ill_instr,

                    o_csr_sel,o_csr_rd,o_csr_we,

                    o_csr_wr_addr,o_csr_rd_addr,o_csr_op

);

input i_clk;
input i_rstn;
input i_stall;
input i_flush;
input i_instr_valid;
input [31:0] i_instr;
input [31:0] i_pc;
input [31:0] i_src1;
input [31:0] i_src2;
output reg [4:0] o_src1_addr;
output reg [4:0] o_src2_addr;
output [31:0] o_rs1;
output [31:0] o_rs2;
output reg [31:0] o_imm;
output reg [31:0] o_pc;
output reg o_instr_valid;
output reg [1:0] o_rs1_fwsel;
output reg [1:0] o_rs2_fwsel;
output reg o_mem_fwsel;
output reg o_cmp_op1sel;
output reg [1:0] o_op1_sel;
output reg [1:0] o_op2_sel;
output reg o_br_en;
output reg [2:0] o_br_type;
output reg [3:0] o_alu_opsel;
output reg o_op_sign;
output reg [1:0] o_exe_res_sel;
output reg [1:0] o_mem_store_type;
output reg [2:0] o_mem_load_type;
output reg o_wb_en;
output reg [4:0] o_wb_reg;
output reg o_wb_data_sel;
output reg o_mem_en;
output reg o_mem_we;
output [31:0] o_mem_data;
output o_stall;
output reg o_except_ill_instr;
output reg o_csr_sel;
output reg o_csr_rd;
output reg o_csr_we;
output reg [11:0] o_csr_wr_addr;
output reg [11:0] o_csr_rd_addr;
output reg [1:0] o_csr_op;

wire [31:0] instr;
wire [11:0] csr_address;
reg [7:0] uc_addr;
wire [1:0] store_type;

wire  wb_we          ;
wire  wb_data_sel    ;
wire  mem_en         ;
wire  mem_we         ;
wire  [2:0] mem_load_type  ;
wire  br_en          ;
wire  [2:0] br_type        ;
wire  cmp_op1sel     ;
wire  [1:0] exe_res_sel    ;
wire  [3:0] alu_op_sel     ;
wire  [1:0] p2_sel        ;
wire  [1:0] op1_sel        ;
wire  [1:0]mm_sel        ;
wire  op_sign        ;
wire  [1:0]csr_op         ;
wire  csr_d_type     ;
wire  csr_sel        ;
reg [31:0] uc;
wire except_ill_instr;
wire csr_rd;
wire csr_we;
wire [31:0] immu;
wire [31:0] immi;
wire [31:0] immj;
wire [31:0] immb;
wire [31:0] imms;
wire [31:0] immu_u;
wire [31:0] immu_i;
wire [31:0] immu_j;
wire [31:0] immu_b;
wire [31:0] immu_s;
wire [31:0] imms_u;
wire [31:0] imms_i;
wire [31:0] imms_j;
wire [31:0] imms_b;
wire [31:0] imms_s;
wire [31:0] imm_r;

reg [4:0] fw_bu00[2:0];
reg [2:0] wb_we_buff;
reg [2:0] wb_wr_buff;
reg [2:0] wb_rd_buff;
//reg stall_d1;
wire [2:0] funct3;
wire [6:0] funct7;
wire [31:0] rs1_csr;
wire [31:0] csr_data;
assign instr= ~i_flush? i_instr  : 32'h33;
assign opcode = instr[6 : 0];
assign rd = instr[11 : 7];
assign funct3 = instr[14 : 12];
assign rs1 = instr[19 : 15];
assign rs2 = instr[24 : 20];
assign funct7 = instr[31 : 25];

assign imms_i =    {{8{instr[31]}},instr[31 : 20]};
assign imms_s =    {{8{instr[31]}},instr[31 : 25] , instr[11 : 7]};
assign imms_u =    {instr[31 : 12] , 12'h0};
assign imms_b =    {{19{instr[31]}},instr[31] , instr[7] , instr[30 : 25] , instr[11 : 8] , 1'b0};
assign imms_j =    {{11{instr[31]}},instr[31 ]  , instr[19 : 12] , instr[20] , instr[ 30 : 21]  , 1'b0};

assign immu_i =    {{8{1'b0}},instr[31 : 20]};
assign immu_s =    {{8{1'b0}},instr[31 : 25] , instr[11 : 7]};
assign immu_u =    {instr[31 : 12] , 12'h0};
assign immu_b =    {{19{1'b0}},instr[31] , instr[7] , instr[30 : 25] , instr[11 : 8] , 1'b0};
assign immu_j =    {{11{1'b0}},instr[31 ]  , instr[19 : 12] , instr[20] , instr[ 30 : 21]  , 1'b0};

assign imm_r = {27'h0,rs2};


assign csr_address= uc_addr == 8'h30 ? 12'h341 : instr[31 : 20] ;
assign o_uc_addr        = uc_addr;
assign store_type       =uc[1 : 0];
assign wb_we            =uc[2];
assign wb_data_sel      =uc[3];
assign mem_en           =uc[4];
assign mem_we           =uc[5];
assign mem_load_type    =uc[8 : 6];
assign br_en            =uc[9];
assign br_type          =uc[12 : 10];
assign cmp_op1sel      =uc[13];
assign exe_res_sel      =uc[15 : 14];
assign alu_op_sel       =uc[19 : 16];
assign op2_sel          =uc[21 : 20];
assign op1_sel          =uc[23 : 22];
assign imm_sel          =uc[26 : 24];
assign op_sign          =uc[27];
assign csr_op          = uc[29 : 28];
assign csr_d_type       = uc[30];
assign csr_sel          = uc[31];





assign rs1_csr=csr_sel? csr_data:i_src1;
assign csr_we=csr_sel & ((csr_op==2'b01 & rs1 != 5'd0) | csr_op[1]);
assign csr_rd=csr_sel & ((csr_op[1] & rs1 != 5'd0) | csr_op==2'b01 | csr_op ==2'b00);

assign csr_data = ~csr_d_type ? i_src1 : {{27{1'b0}},rs1};


assign except_ill_instr = (uc_addr ==0) & (i_rstn);

always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        
        o_csr_sel       <=1'b0;
        o_csr_rd        <=1'b0;       ;
        o_csr_we        <=1'b0;       ;
        o_csr_wr_addr   <='b0     ;
        o_csr_rd_addr   <='b0     ;
        o_csr_op        <='b0     ;
        o_except_ill_instr <='b0       ;
    end else begin
        if (~i_stall) begin
            o_except_ill_instr<=except_ill_instr;
            o_csr_sel       <=csr_sel       ;
            o_csr_rd        <=csr_rd        ;
            o_csr_we        <=csr_we        ;
            o_csr_wr_addr   <=csr_address   ;
            o_csr_rd_addr   <=csr_address   ;
            o_csr_op        <=csr_op ;
        end
    end
end


assign imm_u = op_sign? imms_u : immu_u;
assign imm_i = op_sign? imms_i : immu_i;
assign imm_j = op_sign? imms_j : immu_j;
assign imm_b = op_sign? imms_b : immu_b;
assign imm_s = op_sign? imms_s : immu_s;



assign  imm =   imm_sel == 3'h0 ? imm_u :
                imm_sel == 3'h1 ? imm_i :
                imm_sel == 3'h2 ? imm_j :
                imm_sel == 3'h3 ? imm_b :
                imm_sel == 3'h4 ? imm_r :
                imm_sel == 3'h5 ? imm_s :
                                  32'h0 ;
        

always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn) begin
        fw_bu00[0] <= 5'h0;
        fw_bu00[1] <= 5'h0;
        fw_bu00[2] <= 5'h0;
        wb_we_buff <= 5'h0;
        //wb_wr_buff <= 5'h0;
    end else begin
        if (i_stall) begin
            if (i_flush) begin
                fw_bu00[0] <= 5'h0;
                fw_bu00[1] <= 5'h0;
                fw_bu00[2] <= 5'h0;
                wb_we_buff <= 5'h0;
                //wb_wr_buff <= 5'h0;
            end else begin
                fw_bu00[0] <= rd ;
                if (mem_en) begin
                    fw_bu00[1] <= 5'h0;
                end else begin
                    fw_bu00[1] <= fw_bu00[0];
                end
                fw_bu00[2] <= fw_bu00[1];
                wb_we_buff[0] <= wb_we;
                wb_we_buff[1] <= wb_we_buff[0];
                wb_we_buff[2] <= wb_we_buff[1];
                //wb_wr_buff[0] <= mem_en & mem_we;
                //wb_wr_buff[1] <= wb_wr_buff[0];
                //wb_wr_buff[2] <= wb_wr_buff[1];
                //wb_rd_buff[0] <= mem_en & (~ mem_we);
                //wb_rd_buff[1] <= wb_rd_buff[0];
                //wb_rd_buff[2] <= wb_rd_buff[1];
            end
        end
    end
end

assign mem_fwsel= mem_en & rs2 == fw_bu00[0]  & wb_we_buff[0] & rs2 !=32'h0 ;


//always @(posedge i_clk,negedge i_rstn) begin
//    if (~i_rstn) begin
//        stall_d1<= 1'b0;
//    end else begin
//        stall_d1<= i_stall;
//    end
//end

assign rs1_fwsel =  fw_bu00[0] == rs1 & wb_we_buff[0]  & rs1!=32'h0 ? 2'h1 :
                fw_bu00[1] == rs1 & wb_we_buff[1] & rs1 !=32'h0  ? 2'h2 :
                fw_bu00[2] == rs1 & wb_we_buff[2] & rs1 !=32'h0  ? 2'h3 :
                2'b0;
                
assign rs2_fwsel = fw_bu00[0] == rs2 & wb_we_buff[0] & rs2 !=32'h0 ? 2'h1:
                fw_bu00[1] == rs2 & wb_we_buff[1] & rs2 !=32'h0 ? 2'h2:
                fw_bu00[2] == rs2 & wb_we_buff[2] & rs2 !=32'h0 ? 2'h3:
                2'b0;

assign mem_wr= mem_en ;
assign o_stall=1'b0;


always@(opcode,funct3,funct7) 
begin
    if (opcode == 7'b0110111) begin
        uc_addr <= 8'h01;
        uc  <= 32'b00001000111000000000000000000100;
    end else if (opcode == 7'b0010111) begin
        uc_addr <= 8'h02;
        uc  <= 32'b00001000101000000000000000000100;
    end else if (opcode == 7'b1101111) begin
        uc_addr <= 8'h03;
        uc  <= 32'b00001010101000000101001000000100;
    end else if (opcode == 7'b1100111) begin
        uc_addr <= 8'h04;
        uc  <= 32'b00001001001000000101001000000100;
    end else if (opcode == 7'b1100011) begin
            if (funct3 == 3'b000) begin
                uc_addr <= 8'h05;
                uc  <= 32'b00001011101000000000001000000000;
            end else if (funct3 == 3'b001) begin
                uc_addr <= 8'h06;
                uc  <= 32'b00001011101000000000011000000000;
            end else if (funct3 == 3'b100) begin
                uc_addr <= 8'h07;
                uc  <= 32'b00001011101000000000101000000000;
            end else if (funct3 == 3'b101) begin
                uc_addr <= 8'h08;
                uc  <= 32'b00001011101000000000111000000000;
            end else if (funct3 == 3'b110) begin
                uc_addr <= 8'h09;
                uc  <= 32'b00000011101000000000101000000000;
            end else if (funct3 == 3'b111) begin
                uc_addr <= 8'h0a;
                uc  <= 32'b00000011101000000000111000000000;
            end else begin
                uc_addr <= 8'h00;
                uc  <= 32'b00000000000000000000000000000000;
            end
    end else if (opcode == 7'b0000011) begin
            if (funct3 == 3'b000) begin
                uc_addr <= 8'h0b;
                uc  <= 32'b00001001001000000000000000011100;
            end else if (funct3 == 3'b001) begin
                uc_addr <= 8'h0c;
                uc  <= 32'b00001001001000000000000001011100;
            end else if (funct3 == 3'b010) begin
                uc_addr <= 8'h0d;
                uc  <= 32'b00001001001000000000000010011100;
            end else if (funct3 == 3'b100) begin
                uc_addr <= 8'h0e;
                uc  <= 32'b00000001001000000000000011011100;
            end else if (funct3 == 3'b101) begin
                uc_addr <= 8'h0f;
                uc  <= 32'b00000001001000000000000100011100;
            end else begin
                uc_addr <= 8'h00;
                uc  <= 32'b00000000000000000000000000000000;
            end
    end else if (opcode == 7'b0100011) begin
            if (funct3 == 3'b000) begin
                uc_addr <= 8'h10;
                uc  <= 32'b00001101001000000000000000110000;
            end else if (funct3 == 3'b001) begin
                uc_addr <= 8'h11;
                uc  <= 32'b00001101001000000000000000110001;
            end else if (funct3 == 3'b010) begin
                uc_addr <= 8'h12;
                uc  <= 32'b00001101001000000000000000110010;
            end else begin
                uc_addr <= 8'h00;
                uc  <= 32'b00000000000000000000000000000000;
            end
    end else if (opcode == 7'b0010011) begin
            if (funct3 == 3'b000) begin
                uc_addr <= 8'h13;
                uc  <= 32'b00001001001000000000000000000100;
            end else if (funct3 == 3'b001) begin
                uc_addr <= 8'h19;
                uc  <= 32'b00001100001001010000000000000100;
            end else if (funct3 == 3'b010) begin
                uc_addr <= 8'h14;
                uc  <= 32'b00001001001000011010000000000100;
            end else if (funct3 == 3'b011) begin
                uc_addr <= 8'h15;
                uc  <= 32'b00000001001000011010000000000100;
            end else if (funct3 == 3'b100) begin 
                uc_addr <= 8'h16;
                uc  <= 32'b00001001001000100000000000000100;
            end else if (funct3 == 3'b110) begin
                uc_addr <= 8'h17;
                uc  <= 32'b00001001001000110000000000000100;
            end else if (funct3 == 3'b111) begin
                uc_addr <= 8'h18;
                uc  <= 32'b00001001001000110000000000000100;
            end else if (funct3 == 3'b101) begin
                if (funct7[5] == 1'b0) begin
                    uc_addr <= 8'h1b;
                    uc  <= 32'b00001100001001110000000000000100;
                end else begin
                    uc_addr <= 8'h1a;
                    uc  <= 32'b00001100001001100000000000000100;
                end
            end else begin
                uc_addr <= 8'h00;
                uc  <= 32'b00000000000000000000000000000000;
            end
    end else if (opcode == 7'b0110011) begin
            if (funct3 == 3'b000) begin
                if (funct7[5] == 1'b0) begin
                    uc_addr <= 8'h1c;
                    uc  <= 32'b00001000000000000000000000000100;
                end else begin
                    uc_addr <= 8'h1d;
                    uc  <= 32'b00001000000000010000000000000100;
                end
            end else if (funct3 == 3'b001) begin
                uc_addr <= 8'h1e;
                uc  <= 32'b00001000000001010000000000000100;
            end else if (funct3 == 3'b010) begin
                uc_addr <= 8'h1f;
                uc  <= 32'b00001000000000001000000000000100;
            end else if (funct3 == 3'b011) begin
                uc_addr <= 8'h20;
                uc  <= 32'b00000000000000001000000000000100;
            end else if (funct3 == 3'b100) begin
                uc_addr <= 8'h21;
                uc  <= 32'b00001000000000100000000000000100;
            end else if (funct3 == 3'b101) begin
                if (funct7[5] == 1'b0) begin
                    uc_addr <= 8'h22;
                    uc  <= 32'b00001000000001100000000000000100;
                end else begin
                    uc_addr <= 8'h23;
                    uc  <= 32'b00001000000001110000000000000100;
                end
            end else if (funct3 == 3'b110) begin
                uc_addr <= 8'h24;
                uc  <= 32'b00001000000001000000000000000100;
            end else if (funct3 == 3'b111) begin
                uc_addr <= 8'h25;
                uc  <= 32'b00001000000000110000000000000100;
            end else begin
                uc_addr <= 8'h00;
                uc  <= 32'b00000000000000000000000000000000;
            end
    end else if (opcode == 7'b0001111) begin
            if (funct3 == 3'b000) begin
                uc_addr <= 8'h26;
                uc  <= 32'b00001000101000000000000000000000;
            end else if (funct3 == 3'b001) begin
                uc_addr <= 8'h27;
                uc  <= 32'b00001000101000000000000000000000;
            end else begin
                uc_addr <= 8'h00;
                uc  <= 32'b00000000000000000000000000000000;
            end
    end else if (opcode == 7'b1110011) begin
            if (funct3 == 3'b000) begin
                if (immu_i == 32'h00000000) begin
                    uc_addr <= 8'h28;
                    uc  <= 32'b00001000101000000000000000000000;
                end else if (immu_i == 32'h00000001) begin
                    uc_addr <= 8'h29;
                    uc  <= 32'b00001000101000000000000000000000;
                end else if (immu_i == 32'h00000302) begin
                    uc_addr <= 8'h30;
                    uc  <= 32'b10001110111000000001001000000000;
                end
            end else if (funct3 == 3'b001) begin
                uc  <= 32'b10011110111000000000000000000100;
                uc_addr <= 8'h2a;
            end else if (funct3 == 3'b010) begin
                uc  <= 32'b10101110111000000000000000000100;
                uc_addr <= 8'h2b;
            end else if (funct3 == 3'b011) begin
                uc  <= 32'b10111110111000000000000000000100;
                uc_addr <= 8'h2c;
            end else if (funct3 == 3'b101) begin
                uc  <= 32'b11011110111000000000000000000100;
                uc_addr <= 8'h2d;
            end else if (funct3 == 3'b110) begin
                uc  <= 32'b11101110111000000000000000000100;
                uc_addr <= 8'h2e;
            end else if (funct3 == 3'b111) begin
                uc  <= 32'b11111110111000000000000000000100;
                uc_addr <= 8'h2f;
            end else begin
            uc_addr <= 8'h00;
            uc  <= 32'b00000000000000000000000000000000;
            end
    end else begin
        uc_addr <= 8'h00;
        uc  <= 32'b00000000000000000000000000000000;
        
    end
end 



always @(posedge i_clk,negedge i_rstn) begin
    if (~i_rstn ) begin
    
        o_imm           <= 'b0 ;
        o_pc            <= 'b0 ;
        o_op1_sel       <= 'b0 ;
        o_op2_sel       <= 'b0 ;
        o_br_en         <= 'b0 ;
        o_br_type       <= 'b0 ;
        o_cmp_op1sel    <= 'b0 ;
        o_alu_opsel     <= 'b0 ;
        o_exe_res_sel   <= 'b0 ;
        o_mem_store_type<= 'b0 ;
        o_mem_load_type <= 'b0 ;
        o_wb_en         <= 'b0 ;
        o_wb_reg        <= 'b0 ;
        o_wb_data_sel   <= 'b0 ;
        o_mem_en        <= 'b0 ;
        o_mem_we        <= 'b0 ;
        //o_mem_data    <= 'b0 ;
        o_op_sign       <= 'b0 ;
        o_rs1_fwsel     <= 'b0 ;
        o_rs2_fwsel     <= 'b0 ;
        o_src1_addr     <= 'b0 ;
        o_src2_addr     <= 'b0 ;
        o_mem_fwsel     <= 'b0 ;
        
        o_instr_valid        <= 'b0             ;
    end else  begin
        if (~i_stall ) begin
            o_imm           <= imm           ;
            o_pc            <= i_pc          ;
            o_op1_sel       <= op1_sel       ;
            o_op2_sel       <= op2_sel       ;
            o_br_en         <= br_en         ;
            o_br_type       <= br_type       ;
            o_cmp_op1sel    <= cmp_op1sel    ;
            o_alu_opsel     <= alu_op_sel    ;
            o_exe_res_sel   <= exe_res_sel   ;
            o_mem_store_type<= store_type    ;
            o_mem_load_type <= mem_load_type ;
            o_wb_en         <= wb_we         ;
            o_wb_reg        <= rd            ;
            o_wb_data_sel   <= wb_data_sel   ;
            o_mem_en        <= mem_en        ;
            o_mem_we        <= mem_we        ;
            o_op_sign       <= op_sign       ; 
            o_rs1_fwsel     <= rs1_fwsel     ;
            o_rs2_fwsel     <= rs2_fwsel     ;
            o_mem_fwsel     <= mem_fwsel     ;
            o_src1_addr     <= rs1;
            o_src2_addr     <= rs2;
            o_instr_valid  <= i_instr_valid;

        end 
    end 
end 

assign  o_rs1           = rs1_csr        ;
assign  o_rs2           = i_src2        ;
assign  o_mem_data      = i_src2        ;

endmodule

