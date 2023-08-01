library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

entity DW_sqrt_func is
  generic ( radicand_width : positive := 8);
port ( radicand     : in  std_logic_vector(radicand_width-1 downto 0);
    square_root_uns : out std_logic_vector((radicand_width+1)/2-1 downto 0);
    square_root_tc  : out std_logic_vector((radicand_width+1)/2-1 downto 0));
end DW_sqrt_func;

architecture func of DW_sqrt_func is
begin
  -- function calls for unsigned/signed square root
  square_root_uns <= std_logic_vector(DWF_sqrt (unsigned(radicand)));
  square_root_tc  <= std_logic_vector(DWF_sqrt (signed(radicand)));
end func;

