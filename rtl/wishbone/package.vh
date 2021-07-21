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
//Description : wishbone structure package
//
////////////////////////////////////////////////////////////////////

`define WB_M2S [70:0]
`define WB_S2M [32:0]

`define addr [70:39]
`define sel [38:35]
`define cyc [34]
`define stb [33]
`define data [32:1] 
`define we [0]

`define ack [0]

`define ADDR [70:39]
`define SEL [38:35]
`define CYC [34]
`define STB [33]
`define DATA [32:1] 
`define WE [0]

`define ACK [0]

`define MASK_ADDR {71'h007fffffffff}


