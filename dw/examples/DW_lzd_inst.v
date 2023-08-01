module DW_lzd_inst( inst_a, dec_inst, enc_inst );

parameter a_width     = 8;
parameter enc_width   = 4;  // ceil(log2(a_width))+1

input  [a_width-1 : 0] inst_a;
output [a_width-1 : 0] dec_inst;
output [enc_width-1 : 0] enc_inst;

    // Instance of DW_lzd
    DW_lzd #(a_width)
	  U1 ( .a(inst_a), .dec(dec_inst), .enc(enc_inst) );

endmodule

