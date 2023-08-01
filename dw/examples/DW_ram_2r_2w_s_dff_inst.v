module DW_ram_2r_2w_s_dff_inst(
          clk, rst_n,
          en_w1_n, addr_w1, data_w1,
          en_w2_n, addr_w2, data_w2,
          en_r1_n, addr_r1, data_r1,
          en_r2_n, addr_r2, data_r2 );

parameter width = 8;
parameter addr_width = 3;
parameter rst_mode = 0;

input clk;
input rst_n;
input en_w1_n;
input [addr_width-1 : 0] addr_w1;
input [width-1 : 0] data_w1;
input en_w2_n;
input [addr_width-1 : 0] addr_w2;
input [width-1 : 0] data_w2;
input en_r1_n;
input [addr_width-1 : 0] addr_r1;
output [width-1 : 0] data_r1;
input en_r2_n;
input [addr_width-1 : 0] addr_r2;
output [width-1 : 0] data_r2;

    // Instance of DW_ram_2r_2w_s_dff
    DW_ram_2r_2w_s_dff #(width, addr_width, rst_mode)
      U1 (
         .clk(clk), .rst_n(rst_n),

         .en_w1_n(en_w1_n), .addr_w1(addr_w1), .data_w1(data_w1),
         .en_w2_n(en_w2_n), .addr_w2(addr_w2), .data_w2(data_w2),

         .en_r1_n(en_r1_n), .addr_r1(addr_r1), .data_r1(data_r1),
         .en_r2_n(en_r2_n), .addr_r2(addr_r2), .data_r2(data_r2)
         );

endmodule
