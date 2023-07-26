
module LFSR (clk, rst, out);

parameter WIDTH = 4;

input clk, rst;
output reg [WIDTH-1:0] out;

always @(posedge clk or negedge rst) begin
  if (!rst) out <= 'hf;
  out <= {out[WIDTH-2:0], out[WIDTH-1] ^ out[WIDTH-2]};
end

endmodule
