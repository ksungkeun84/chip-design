module DW_ecc_inst(allow_correct_n, wr_data_sys, rd_data_mem,
                   rd_checkbits, rd_error, real_bad_rd_error,
                   wr_checkbits, rd_data_sys, error_syndrome);
  parameter wdth = 64;    // 64-bit data busses
  parameter cbts = 8;     // 8-bit check field

  input allow_correct_n;
  input [wdth-1:0] wr_data_sys, rd_data_mem;
  input [cbts-1:0] rd_checkbits;
  output rd_error, real_bad_rd_error;
  output [wdth-1:0] rd_data_sys;
  output [cbts-1:0] wr_checkbits, error_syndrome;

  // instance of DW_ecc for memory reads, uses rd_data_mem
  // and rd_checkbits to derive corrected data on rd_data_sys,
  // error flags on rd_error & real_bad_rd_error, and error
  // syndrome value on error_syndrome

  DW_ecc #(wdth,cbts,1) 
    U1 (.gen( 1'b0 ),                     // gen tied low for read
        .correct_n( allow_correct_n ),    // correct_n from system
        .datain( rd_data_mem ),           // datain from memory
        .chkin( rd_checkbits ),           // chkin also from memory
        .err_detect( rd_error ),          // error flag to system
        .err_multpl( real_bad_rd_error ), // severe error flag to system
        .dataout( rd_data_sys ),          // read data (corrected if allowed)
        .chkout( error_syndrome ) );      // error syndrome for logging

  // instance of DW_ecc fro memory writes, uses wr_data_sys to
  // generate wr_checkbits

  DW_ecc #(wdth,cbts,0) 
    U2(1'b1,                   // gen tied high for write
       1'b1,                   // correct_n not needed (tied high)
       wr_data_sys,            // datain from system bus
       { cbts{1'b0} },         // chkin bus not needed (tied low)
       ,                       // no error flag for writes
       ,                       // no multi error flag for writes
       ,                       // no data modification for writes
       wr_checkbits );         // check bits written to memory
endmodule
