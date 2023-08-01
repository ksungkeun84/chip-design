
module LFSR (clk, rst, seed, out);

parameter WIDTH = 4;

input clk, rst;
input       [WIDTH-1:0] seed;
output reg  [WIDTH-1:0] out;

always @(posedge clk or negedge rst) begin
  if (!rst) out <= seed;
  else out <= {out[WIDTH-2:0], out[WIDTH-1] ^ out[WIDTH-2]};
end

endmodule
