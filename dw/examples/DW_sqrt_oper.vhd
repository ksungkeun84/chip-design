library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

entity DW_sqrt_oper is

  generic ( radicand_width : positive := 8);
  port ( radicand   : in  std_logic_vector(radicand_width-1 downto 0);
    square_root_uns : out std_logic_vector((radicand_width+1)/2-1 downto 0);
    square_root_tc  : out std_logic_vector((radicand_width+1)/2-1 downto 0));
end DW_sqrt_oper;

architecture oper of DW_sqrt_oper is
begin
  -- operators for unsigned/signed square root
  square_root_uns <= unsigned(radicand) ** one_half;
  square_root_tc  <= signed(radicand) ** one_half;
end oper;

