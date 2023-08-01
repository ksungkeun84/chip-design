module DWF_dp_blend_test (x_pict, y_pict, x_text, y_text, z_text, alpha, z);

  input  [15:0] x_pict, y_pict;
  input  [15:0] x_text, y_text, z_text;
  input   [7:0] alpha;
  output [15:0] z;

  // Passes the parameters to the function
  parameter width       = 16;
  parameter alpha_width = 8;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_blend_function.inc"

  assign z = DWF_dp_blend (x_pict + x_text, y_pict + y_text, alpha) + z_text;

endmodule
