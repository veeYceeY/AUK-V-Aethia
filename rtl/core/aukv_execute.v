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
//Description : Execute
//
////////////////////////////////////////////////////////////////////

module aukv_execute(
            i_clk           ,
            i_rstn           ,
            i_stall         ,
            i_flush         ,
            i_rs1           ,
            i_rs2           ,
            i_fw_ee         ,
            i_fw_me         ,
            i_fw_we         ,
            i_imm           ,
            i_pc            ,
            o_pc            ,
            i_instr_valid   ,
            o_instr_valid   ,
            i_illegal       ,
            o_illegal       ,
            i_rs1_addr      ,
            i_rs2_addr      ,
            o_rs1_addr      ,
            o_rs2_addr      ,
            i_rs1_fwsel     ,
            i_rs2_fwsel     ,
            i_mem_fwsel     ,
            i_cmp_op1_sel    ,
            i_op1_sel       ,
            i_op2_sel       ,
            i_signed_op     ,
            i_alu_sel       ,
            i_res_sel       ,
            i_br_addr_sel   ,
            i_br_type_sel   ,
            i_br_en         ,
            i_mem_wr_data   ,
            i_mem_we        ,
            i_mem_en        ,
            i_load_type     ,
            i_store_type    ,
            i_wb_data_sel   ,
            i_wb_reg_sel    ,
            i_wb_we         ,
            o_mem_fwsel     ,
            o_exe_res       ,
            o_br_addr       ,
            o_br_en         ,
            o_mem_wr_data   ,
            o_mem_addr      ,
            o_mem_we        ,
            o_mem_en        ,
            o_wb_data_sel   ,
            o_wb_reg_sel    ,
            o_wb_we         ,
            o_load_type     ,
            o_store_type    ,
            i_csr_sel       ,
            i_csr_rd        ,
            i_csr_we        ,
            //i_csr_wr_data ,
            i_csr_wr_addr   ,
            i_csr_rd_addr   ,
            i_csr_op        ,
            //o_csr_sel     ,
            o_csr_rd        ,
            o_csr_we        ,
            o_csr_wr_data   ,
            o_csr_wr_addr   ,
            o_csr_rd_addr   ,
            o_csr_op        ,
            i_csr_rd_data   
            
            
         );
input i_clk           ;
input i_rstn           ;
input i_stall         ;
input i_flush         ;
input [31:0] i_rs1           ;
input [31:0] i_rs2           ;
input [31:0] i_fw_ee         ;
input [31:0] i_fw_me         ;
input [31:0] i_fw_we         ;
input [31:0] i_imm           ;
input [31:0] i_pc            ;
output reg [31:0] o_pc            ;
input i_instr_valid   ;
output  reg o_instr_valid   ;
input i_illegal       ;
output reg  o_illegal       ;
input [4:0] i_rs1_addr      ;
input [4:0] i_rs2_addr      ;
output reg [4:0] o_rs1_addr      ;
output reg [4:0] o_rs2_addr      ;
input [1:0] i_rs1_fwsel     ;
input [1:0] i_rs2_fwsel     ;
input i_mem_fwsel     ;
input i_cmp_op1_sel    ;
input [1:0] i_op1_sel       ;
input [1:0] i_op2_sel       ;
input i_signed_op     ;
input [3:0] i_alu_sel       ;
input [1:0] i_res_sel       ;
input i_br_addr_sel   ;
input [2:0] i_br_type_sel   ;
input i_br_en         ;
input [31:0] i_mem_wr_data   ;
input i_mem_we        ;
input i_mem_en        ;
input [2:0]i_load_type     ;
input [1:0]i_store_type    ;
input i_wb_data_sel   ;
input [4:0]i_wb_reg_sel    ;
input i_wb_we         ;
output reg o_mem_fwsel    ;
output reg [31:0] o_exe_res      ;
output reg [31:0] o_br_addr      ;
output reg o_br_en        ;
output reg [31:0] o_mem_wr_data  ;
output reg [31:0] o_mem_addr     ;
output reg o_mem_we       ;
output reg o_mem_en       ;
output reg o_wb_data_sel  ;
output reg [4:0] o_wb_reg_sel   ;
output reg o_wb_we        ;
output reg [2:0] o_load_type    ;
output reg [1:0] o_store_type   ;
input i_csr_sel       ;
input i_csr_rd        ;
input i_csr_we        ;
//i_csr_wr_data ,     ;
input [11:0] i_csr_wr_addr   ;
input [11:0]i_csr_rd_addr   ;
input [1:0] i_csr_op        ;
//o_csr_sel     ,
output o_csr_rd        ;
output o_csr_we        ;
output [31:0] o_csr_wr_data   ;
output [11:0] o_csr_wr_addr   ;
output [11:0] o_csr_rd_addr   ;
output [1:0] o_csr_op        ;
input [31:0] i_csr_rd_data   ;


wire  [31:0] operand1  ;
wire  [31:0] operand2  ;
wire  [31:0] alu0_result  ;
wire  [31:0] set_res  ;
wire  [31:0] branch_res  ;
wire  [31:0] branch_address  ;
wire  [31:0] mem_address  ;
wire  [31:0] rd  ;
wire  alu0_ov  ;
wire  imm_type  ;
wire  mem_we  ;
wire  alu0_lt  ;
wire  alu0_ge  ;
wire  alu0_eq  ;
wire  alu0_ne  ;
wire  cp0_lt  ;
wire  cp0_ge  ;
wire  cp0_eq  ;
wire  cp0_ne  ;
wire  [31:0] ZERO32  ;
wire  [31:0] FOUR32  ;
wire  cmp_result  ;
wire  br_en  ;
wire  [31:0] set_result  ;
wire  [31:0] next_instr_addr  ;
wire  [31:0] branch_addr  ;
wire  [31:0] exe_result  ;
wire  [31:0] rs1  ;
wire  [31:0] rs2  ;
wire  [31:0] cmp_op1  ;
wire  [31:0] mem_data  ;
wire  [31:0] csr_wr_data  ;
wire  [31:0] wb_data  ;



assign o_csr_rd        =i_csr_rd        ;
assign o_csr_we        =i_csr_we        ;
assign o_csr_wr_data   =rs1   ;
assign o_csr_wr_addr   =i_csr_wr_addr   ;
assign o_csr_rd_addr   =i_csr_rd_addr   ;
assign o_csr_op        =i_csr_op        ;


assign wb_data = i_csr_sel ? i_csr_rd_data : exe_result;

assign rs1= i_rs1_fwsel == 2'h0 ? i_rs1 :
            i_rs1_fwsel == 2'h1 ? i_fw_ee :
            i_rs1_fwsel == 2'h2 ? i_fw_me :
                                 i_rs1 ;
assign rs2= i_rs2_fwsel == 2'h0 ? i_rs2 :
            i_rs2_fwsel == 2'h1 ? i_fw_ee :
            i_rs2_fwsel == 2'h2 ? i_fw_me :
                                 i_rs2 ;

assign ZERO32 = 'h0;
assign FOUR32 = 'h4;

assign operand1= i_op1_sel == 2'h0 ? rs1 :
            i_op1_sel == 2'h1 ? rs2 :
            i_op1_sel == 2'h2 ? i_pc :
                              ZERO32 ;
assign operand2= i_op2_sel == 2'h0 ? rs2 :
            i_op2_sel == 2'h1 ? rs1 :
            i_op2_sel == 2'h2 ? i_imm :
                              ZERO32 ;
             
             
assign cmp_op1 = ~i_cmp_op1_sel ? rs2 : i_imm;
aukv_alu ALU0 (
            .i_clk       (i_clk),
            .i_rstn       (i_rstn),   
            .i_operation (i_alu_sel),
            .i_rs1       (operand1),
            .i_rs2       (operand2),
            .o_rd        (alu0_result),
            .i_cmp_a         (rs1),
            .i_cmp_b         (cmp_op1),
            .i_cmp_sign      (i_signed_op),
            .o_lt        (cp0_lt),
            .o_ge        (cp0_ge),
            .o_eq        (cp0_eq),
            .o_ne        (cp0_ne)
);

assign cmp_result = i_br_type_sel == 3'h0 ? cp0_eq :
                    i_br_type_sel == 3'h1 ? cp0_ne :
                    i_br_type_sel == 3'h2 ? cp0_lt :
                    i_br_type_sel == 3'h3 ? cp0_ge :
                    i_br_type_sel == 3'h4 ? 1'b1   : 
                    1'b0;
assign set_result = {31'h0,cmp_result};

assign next_instr_addr = i_pc+FOUR32;

assign branch_addr = i_csr_sel ? i_csr_rd_data : 
                     ~i_br_addr_sel ? alu0_result : i_imm;

assign exe_result = i_res_sel == 2'h0 ? alu0_result :
                    i_res_sel == 2'h2 ? set_result  :
                    next_instr_addr;

                
assign mem_address =  alu0_result;

assign br_en= cmp_result & i_br_en;

assign mem_data = i_rs2_fwsel == 2'h0 ? i_mem_wr_data :
                  i_rs2_fwsel == 2'h1 ? i_fw_ee :
                  i_rs2_fwsel == 2'h2 ? i_fw_me :
                  i_mem_wr_data;


always @( posedge i_clk,negedge i_rstn)
begin
    if (~i_rstn ) begin
    
        o_br_addr       <= 'b0;
        o_br_en         <= 'b0;
        o_exe_res       <= 'b0;
        o_mem_wr_data   <= 'b0;
        o_mem_addr      <= 'b0;
        o_mem_we        <= 'b0;
        o_wb_data_sel   <= 'b0;
        o_wb_reg_sel    <= 'b0;
        o_wb_we         <= 'b0;
        o_mem_en        <= 'b0;
        o_load_type     <= 'b0;
        o_store_type    <= 'b0;
        o_pc            <= 'b0;
        o_instr_valid   <= 'b0;
        
    end else begin
        if (~i_stall) begin
            if (i_flush) begin
                o_mem_fwsel     <= 'b0;
                o_br_addr       <= 'b0;
                o_br_en         <= 'b0;
                o_exe_res       <= 'b0;
                o_mem_wr_data   <= 'b0;
                o_mem_addr      <= 'b0;
                o_mem_we        <= 'b0;
                o_wb_data_sel   <= 'b0;
                o_wb_reg_sel    <= 'b0;
                o_wb_we         <= 'b0;
                o_mem_en        <= 'b0;
                o_load_type     <= 'b0;
                o_store_type    <= 'b0;
                o_illegal       <= 'b0;
            end else begin
                    o_illegal      <= i_illegal;
                    o_rs1_addr      <= i_rs1_addr;
                    o_rs2_addr      <= i_rs2_addr;
                    o_mem_fwsel     <= i_mem_fwsel;
                    o_br_addr       <= branch_addr     ;
                    o_br_en         <= br_en           ;
                    o_exe_res       <= wb_data      ;
                    o_mem_wr_data   <= mem_data   ;
                    o_mem_addr      <= mem_address     ;
                    o_mem_we        <= i_mem_we        ;
                    o_wb_data_sel   <= i_wb_data_sel   ;
                    o_wb_reg_sel    <= i_wb_reg_sel    ;
                    o_wb_we         <= i_wb_we         ;
                    o_mem_en        <= i_mem_en        ;
                    o_load_type     <= i_load_type     ;
                    o_store_type    <= i_store_type    ;
            end
            o_pc            <= i_pc;
            o_instr_valid  <= i_instr_valid;
        end
        
    end
end 



endmodule
