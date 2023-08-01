module DW_arb_rr_inst ( 
                inst_clk,
                inst_rst_n,
                inst_init_n,
                inst_enable,
                inst_request,
                
		inst_mask,
                granted_inst,
                grant_inst,
                grant_index_inst );

parameter n = 4;
parameter output_mode = 1;
parameter index_mode = 0;

`define   bit_width_n 2  // ceil(log2(n + (index_mode % 2)))

input inst_clk;
input inst_rst_n;
input inst_init_n;
input inst_enable;
input [n-1 : 0] inst_request;
input [n-1 : 0] inst_mask;
output granted_inst;
output [n-1 : 0] grant_inst;
output [`bit_width_n-1 : 0] grant_index_inst;

    // Instance of DW_arb_rr
    DW_arb_rr #(n,
                output_mode,
                index_mode)
	  U1 (  .clk(inst_clk),
                .rst_n(inst_rst_n),
                .init_n(inst_init_n),
                .enable(inst_enable),
                .request(inst_request),
                .mask(inst_mask),
                .granted(granted_inst),
                .grant(grant_inst),
                .grant_index(grant_index_inst) );
               
endmodule
