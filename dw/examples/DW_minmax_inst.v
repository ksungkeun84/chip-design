// example: instantiation of 4-input minimum/maximum component
module DW_minmax_inst (a0, a1, a2, a3, tc, max, val, idx);

  parameter wordlength = 8;

  input  [wordlength-1 : 0] a0, a1, a2, a3;
  input  tc, max;
  output [wordlength-1 : 0] val;
  output [1 : 0] idx;

  // instantiation of DW_minmax
  // inputs are concatenated into the input vector
  DW_minmax #(wordlength, 4) 
    U1 (.a({a3, a2, a1, a0}), .tc(tc), .min_max(max), 
        .value(val), .index(idx));

endmodule

