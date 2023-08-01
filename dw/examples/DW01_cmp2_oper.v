module DW01_cmp2_oper(in1, in2, instruction, comparison);
  parameter wordlength = 8;

  input [wordlength-1:0] in1, in2;
  input instruction;
  output comparison;
  reg comparison;
 
  always @ (in1 or in2 or instruction)
  begin
    if (instruction == 0)
      comparison = (in1 > in2);
    else
      comparison = (in1 >= in2);
  end
endmodule
