`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/05/2017 10:09:33 PM
// Design Name: 
// Module Name: time_trigger_regs
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//`include "cp2.vh"
`include "bus.vh"
`include "cp2.vh"
`include "signal.vh"
module time_trigger_regs(
    input wire rst, 
    input wire clk,
    input wire [`WORDDATABUS]g_time,
    /*****编号(number)和sel共同选择寄存器*****/
    input wire [`NumAddrBus]r_number,
    input wire [`NumAddrBus]w_number,
    input wire  r_sel,
    input wire  w_sel,
    input wire  wea,
    input wire  rea,
    input wire [`WORDDATABUS]din,
    /******mfc读的输出*******************/
    output wire [`WORDDATABUS]dout,
    /*********TPIN的输出和输入***********/
    inout  [`WORDDATABUS]data
    );
    

    reg [`WORDDATABUS] io_regs[0:`IO_REGS_NUM-1];
    reg [`WORDDATABUS] tr_regs[0:`TR_REGS_NUM-1];
    reg [`WORDDATABUS] tport;

    reg [`NumAddrBus]  error_number;

    wire [`BYTEDATABUS] io_pa_input_buf_status;
    wire [`BYTEDATABUS] io_pb_input_buf_status;
    wire [`BYTEDATABUS] io_pc_input_buf_status;
    wire [`BYTEDATABUS] io_pd_input_buf_status;

    wire [`BYTEDATABUS] io_pa_output_buf_status;
    wire [`BYTEDATABUS] io_pb_output_buf_status;
    wire [`BYTEDATABUS] io_pc_output_buf_status;
    wire [`BYTEDATABUS] io_pd_output_buf_status;

    assign io_pa_input_buf_status=(data[`IO_PA_BUS]&(~io_regs[`IO_DDR][`IO_PA_BUS]));
    assign io_pb_input_buf_status=(data[`IO_PB_BUS]&(~io_regs[`IO_DDR][`IO_PB_BUS]));
    assign io_pc_input_buf_status=(data[`IO_PC_BUS]&(~io_regs[`IO_DDR][`IO_PC_BUS]));
    assign io_pd_input_buf_status=(data[`IO_PD_BUS]&(~io_regs[`IO_DDR][`IO_PD_BUS]));

    assign io_pa_output_buf_status=(io_regs[`IO_TPORT][`IO_PA_BUS]&io_regs[`IO_DDR][`IO_PA_BUS]);
    assign io_pb_output_buf_status=(io_regs[`IO_TPORT][`IO_PB_BUS]&io_regs[`IO_DDR][`IO_PB_BUS]);
    assign io_pc_output_buf_status=(io_regs[`IO_TPORT][`IO_PC_BUS]&io_regs[`IO_DDR][`IO_PC_BUS]);
    assign io_pd_output_buf_status=(io_regs[`IO_TPORT][`IO_PD_BUS]&io_regs[`IO_DDR][`IO_PD_BUS]);
    /******** mfc2 读的输出:sel为1，表明为读tr_regs,sel为0读io_regs。
    ********* i/o regs只有11个，越界输出0********/
    assign dout = (r_sel==1)?((rea)?tr_regs[r_number]:0):
                    ((r_number<11&&rea)?io_regs[r_number]:0);
   
    /*********I/O select,ddr configure***********/
    /*********根据ddr口的位，决定inout口data的输入和输出：ddr口的某位为1
    **********则data口对应的位为输出，输出寄存器tport口的值***********/
    assign data[0:0] = io_regs[`IO_DDR][0:0]?io_regs[`IO_TPIN][0:0]:1'bz;
    assign data[1:1] = io_regs[`IO_DDR][1:1]?io_regs[`IO_TPIN][1:1]:1'bz;
    assign data[2:2] = io_regs[`IO_DDR][2:2]?io_regs[`IO_TPIN][2:2]:1'bz;
    assign data[3:3] = io_regs[`IO_DDR][3:3]?io_regs[`IO_TPIN][3:3]:1'bz;
    assign data[4:4] = io_regs[`IO_DDR][4:4]?io_regs[`IO_TPIN][4:4]:1'bz;
    assign data[5:5] = io_regs[`IO_DDR][5:5]?io_regs[`IO_TPIN][5:5]:1'bz;
    assign data[6:6] = io_regs[`IO_DDR][6:6]?io_regs[`IO_TPIN][6:6]:1'bz;
    assign data[7:7] = io_regs[`IO_DDR][7:7]?io_regs[`IO_TPIN][7:7]:1'bz;
    assign data[8:8] = io_regs[`IO_DDR][8:8]?io_regs[`IO_TPIN][8:8]:1'bz;
    assign data[9:9] = io_regs[`IO_DDR][9:9]?io_regs[`IO_TPIN][9:9]:1'bz;
    assign data[10:10] = io_regs[`IO_DDR][10:10]?io_regs[`IO_TPIN][10:10]:1'bz;
    assign data[11:11] = io_regs[`IO_DDR][11:11]?io_regs[`IO_TPIN][11:11]:1'bz;
    assign data[12:12] = io_regs[`IO_DDR][12:12]?io_regs[`IO_TPIN][12:12]:1'bz;
    assign data[13:13] = io_regs[`IO_DDR][13:13]?io_regs[`IO_TPIN][13:13]:1'bz;
    assign data[14:14] = io_regs[`IO_DDR][14:14]?io_regs[`IO_TPIN][14:14]:1'bz;
    assign data[15:15] = io_regs[`IO_DDR][15:15]?io_regs[`IO_TPIN][15:15]:1'bz;
    assign data[16:16] = io_regs[`IO_DDR][16:16]?io_regs[`IO_TPIN][16:16]:1'bz;
    assign data[17:17] = io_regs[`IO_DDR][17:17]?io_regs[`IO_TPIN][17:17]:1'bz;
    assign data[18:18] = io_regs[`IO_DDR][18:18]?io_regs[`IO_TPIN][18:18]:1'bz;
    assign data[19:19] = io_regs[`IO_DDR][19:19]?io_regs[`IO_TPIN][19:19]:1'bz;
    assign data[20:20] = io_regs[`IO_DDR][20:20]?io_regs[`IO_TPIN][20:20]:1'bz;
    assign data[21:21] = io_regs[`IO_DDR][21:21]?io_regs[`IO_TPIN][21:21]:1'bz;
    assign data[22:22] = io_regs[`IO_DDR][22:22]?io_regs[`IO_TPIN][22:22]:1'bz;
    assign data[23:23] = io_regs[`IO_DDR][23:23]?io_regs[`IO_TPIN][23:23]:1'bz;
    assign data[24:24] = io_regs[`IO_DDR][24:24]?io_regs[`IO_TPIN][24:24]:1'bz;
    assign data[25:25] = io_regs[`IO_DDR][25:25]?io_regs[`IO_TPIN][25:25]:1'bz;
    assign data[26:26] = io_regs[`IO_DDR][26:26]?io_regs[`IO_TPIN][26:26]:1'bz;
    assign data[27:27] = io_regs[`IO_DDR][27:27]?io_regs[`IO_TPIN][27:27]:1'bz;
    assign data[28:28] = io_regs[`IO_DDR][28:28]?io_regs[`IO_TPIN][28:28]:1'bz;
    assign data[29:29] = io_regs[`IO_DDR][29:29]?io_regs[`IO_TPIN][29:29]:1'bz;
    assign data[30:30] = io_regs[`IO_DDR][30:30]?io_regs[`IO_TPIN][30:30]:1'bz;
    assign data[31:31] = io_regs[`IO_DDR][31:31]?io_regs[`IO_TPIN][31:31]:1'bz;
    

//    //TR寄存器的时间触发的刷新
//    always @(posedge clk or `RESET_EDGE rst)begin
//        if(rst==`RESET_ENABLE)
//        begin
//       end else begin
//                    end
//    end
//   
//    //I/O TPIN的时间触发的刷新
//    always @(posedge clk or `RESET_EDGE rst)begin
//        if(rst==`RESET_ENABLE)
//        begin
//        end else begin
//                    end
//    end
    /*********周期寄存器(mask)的写**********/
    /*********buffer寄存器写**********/
    always @(posedge clk or `RESET_EDGE rst)begin
        if(rst==`RESET_ENABLE)
        begin
            tr_regs[0]<=0;
            tr_regs[1]<=0;
            tr_regs[2]<=0;
            tr_regs[3]<=0;
            tr_regs[4]<=0;
            tr_regs[5]<=0;
            tr_regs[6]<=0;
            tr_regs[7]<=0;
 
            io_regs[`IO_TPIN]<=0;

            io_regs[0]<=0;
            io_regs[2]<=0;
            io_regs[3]<=0;
            io_regs[4]<=0;
            io_regs[5]<=0;
            io_regs[6]<=0;
            io_regs[7]<=0;
            io_regs[8]<=0;
            io_regs[9]<=0;
            io_regs[10]<=0;
            tr_regs[8]<=0;
            tr_regs[9]<=0;
            tr_regs[10]<=0;
            tr_regs[11]<=0;
            tr_regs[12]<=0;
            tr_regs[13]<=0;
            tr_regs[14]<=0;
            tr_regs[15]<=0;
            tr_regs[16]<=0;
            tr_regs[17]<=0;
            tr_regs[18]<=0;
            tr_regs[19]<=0;
            tr_regs[20]<=0;
            tr_regs[21]<=0;
            tr_regs[22]<=0;
            tr_regs[23]<=0;
            tr_regs[24]<=0;
            tr_regs[25]<=0;
            tr_regs[26]<=0;
            tr_regs[27]<=0;
            tr_regs[28]<=0;
            tr_regs[29]<=0;
            tr_regs[30]<=0;
            tr_regs[31]<=0;
        end else if(wea) begin  
            if(~w_sel)begin
                case(w_number)
                //Buffer寄存器的写
                `IO_TPORT_ADDR,`IO_DDR_ADDR:io_regs[w_number]<=din;
                //周期Mask寄存器的写
                `IO_PINCY_ADDR_BASE,`IO_PINCY_ADDR_BASE+1,`IO_PINCY_ADDR_BASE+2,`IO_PINCY_ADDR_BASE+3:io_regs[w_number]<=(`WORDDATAW'b1<<din[4:0])-1;
                //相位寄存器的写
                `IO_PINPH_ADDR_BASE,`IO_PINPH_ADDR_BASE+1,`IO_PINPH_ADDR_BASE+2,`IO_PINPH_ADDR_BASE+3:io_regs[w_number]<=din;
                default:error_number<=w_number;
                endcase
            end else begin
                case(w_number)
                //Buffer寄存器的写
                `TR_READB_ADDR_BASE,`TR_READB_ADDR_BASE+1,`TR_READB_ADDR_BASE+2,`TR_READB_ADDR_BASE+3,`TR_READB_ADDR_BASE+4,`TR_READB_ADDR_BASE+5,`TR_READB_ADDR_BASE+6,`TR_READB_ADDR_BASE+7:tr_regs[w_number]<=din;
                //周期Mask寄存器的写
                `TR_CY_ADDR_BASE,`TR_CY_ADDR_BASE+1,`TR_CY_ADDR_BASE+2,`TR_CY_ADDR_BASE+3,`TR_CY_ADDR_BASE+4,`TR_CY_ADDR_BASE+5,`TR_CY_ADDR_BASE+6,`TR_CY_ADDR_BASE+7:tr_regs[w_number]<=(`WORDDATAW'b1<<din[4:0])-1;
                //相位寄存器的写
                `TR_PH_ADDR_BASE,`TR_PH_ADDR_BASE+1,`TR_PH_ADDR_BASE+2,`TR_PH_ADDR_BASE+3,`TR_PH_ADDR_BASE+4,`TR_PH_ADDR_BASE+5,`TR_PH_ADDR_BASE+6,`TR_PH_ADDR_BASE+7:tr_regs[w_number]<=din;
                default:error_number<=w_number;
                endcase
            end
        end else begin
            //没有写操作
            error_number<=5'b0;
            io_regs[`IO_TPIN][`IO_PA_BUS]<=(io_regs[`IO_PINPH_ADDR_BASE]==(g_time&io_regs[`IO_PINCY_ADDR_BASE]))?
                io_pa_input_buf_status+io_pa_output_buf_status:
                io_regs[`IO_TPIN][`IO_PA_BUS];
            io_regs[`IO_TPIN][`IO_PB_BUS]<=(io_regs[`IO_PINPH_ADDR_BASE+1]==(g_time&io_regs[`IO_PINCY_ADDR_BASE+1]))?
                io_pb_input_buf_status+io_pb_output_buf_status:
                io_regs[`IO_TPIN][`IO_PB_BUS];
            io_regs[`IO_TPIN][`IO_PC_BUS]<=(io_regs[`IO_PINPH_ADDR_BASE+2]==(g_time&io_regs[`IO_PINCY_ADDR_BASE+2]))?
                io_pc_input_buf_status+io_pc_output_buf_status:
                io_regs[`IO_TPIN][`IO_PC_BUS];
            io_regs[`IO_TPIN][`IO_PD_BUS]<=(io_regs[`IO_PINPH_ADDR_BASE+3]==(g_time&io_regs[`IO_PINCY_ADDR_BASE+3]))?
                io_pd_input_buf_status+io_pd_output_buf_status:
                io_regs[`IO_TPIN][`IO_PD_BUS];
                
            tr_regs[`TR_READ_ADDR_BASE]<=(tr_regs[`TR_PH_ADDR_BASE]==(g_time&tr_regs[`TR_CY_ADDR_BASE]))?tr_regs[`TR_READB_ADDR_BASE]:tr_regs[`TR_READ_ADDR_BASE];
            tr_regs[`TR_READ_ADDR_BASE+1]<=(tr_regs[`TR_PH_ADDR_BASE+1]==(g_time&tr_regs[`TR_CY_ADDR_BASE+1]))?tr_regs[`TR_READB_ADDR_BASE+1]:tr_regs[`TR_READ_ADDR_BASE+1];
            tr_regs[`TR_READ_ADDR_BASE+2]<=(tr_regs[`TR_PH_ADDR_BASE+2]==(g_time&tr_regs[`TR_CY_ADDR_BASE+2]))?tr_regs[`TR_READB_ADDR_BASE+2]:tr_regs[`TR_READ_ADDR_BASE+2];
            tr_regs[`TR_READ_ADDR_BASE+3]<=(tr_regs[`TR_PH_ADDR_BASE+3]==(g_time&tr_regs[`TR_CY_ADDR_BASE+3]))?tr_regs[`TR_READB_ADDR_BASE+3]:tr_regs[`TR_READ_ADDR_BASE+3];
            tr_regs[`TR_READ_ADDR_BASE+4]<=(tr_regs[`TR_PH_ADDR_BASE+4]==(g_time&tr_regs[`TR_CY_ADDR_BASE+4]))?tr_regs[`TR_READB_ADDR_BASE+4]:tr_regs[`TR_READ_ADDR_BASE+4];
            tr_regs[`TR_READ_ADDR_BASE+5]<=(tr_regs[`TR_PH_ADDR_BASE+5]==(g_time&tr_regs[`TR_CY_ADDR_BASE+5]))?tr_regs[`TR_READB_ADDR_BASE+5]:tr_regs[`TR_READ_ADDR_BASE+5];
            tr_regs[`TR_READ_ADDR_BASE+6]<=(tr_regs[`TR_PH_ADDR_BASE+6]==(g_time&tr_regs[`TR_CY_ADDR_BASE+6]))?tr_regs[`TR_READB_ADDR_BASE+6]:tr_regs[`TR_READ_ADDR_BASE+6];
            tr_regs[`TR_READ_ADDR_BASE+7]<=(tr_regs[`TR_PH_ADDR_BASE+7]==(g_time&tr_regs[`TR_CY_ADDR_BASE+7]))?tr_regs[`TR_READB_ADDR_BASE+7]:tr_regs[`TR_READ_ADDR_BASE+7];


        end
    end
 
endmodule
