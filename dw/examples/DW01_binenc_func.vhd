library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW01_binenc_func is
  generic(func_A_width :integer := 8;func_ADDR_width : integer := 4);
  port(func_A: in std_logic_vector(func_A_width-1 downto 0);
       ADDR_func_TC : out std_logic_vector(func_ADDR_width-1 downto 0);
       ADDR_func_UNS : out std_logic_vector(func_ADDR_width-1 downto 0);
       ADDR_func : out std_logic_vector(func_ADDR_width-1 downto 0));
end DW01_binenc_func;

architecture func of DW01_binenc_func is

begin
  ADDR_func_TC  <= std_logic_vector(DWF_binenc(SIGNED(func_A),
                                    func_ADDR_width));
  ADDR_func_UNS <= std_logic_vector(DWF_binenc(UNSIGNED(func_A),
                                    func_ADDR_width));
  ADDR_func     <= DWF_binenc(func_A,func_ADDR_width);

end func;
