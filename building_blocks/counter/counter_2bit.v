module counter_2bit(clk, rst, up, count);
input clk, rst, up;
output reg [1:0] count;

reg [1:0] nextCount;

always @(up, count) begin
  case (count)
    0: begin
      if (up) nextCount = 1;
      else nextCount = 3;
    end
    1: begin
      if (up) nextCount = 2;
      else nextCount = 0;
    end
    2: begin
      if (up) nextCount = 3;
      else nextCount = 1;
    end
    3: begin
      if (up) nextCount = 0;
      else nextCount = 2;
    end
    default: begin
      nextCount = 0;
    end
  endcase
end

always @(posedge clk or negedge rst) begin
  if (!rst) count <= 0;
  else count <= nextCount;
end

/*
always @(posedge clk or negedge rst) begin
  if (!rst) count <= 0;
  else if (up) count <= count + 1;
  else count <= count -1;
end
*/

endmodule
