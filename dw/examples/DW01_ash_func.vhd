library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW01_ash_func is
  generic(func_A_width:integer:=8; func_SH_width : integer := 3);
  port(func_A: in std_logic_vector(func_A_width-1 downto 0);
       func_DATA_TC : in std_logic;
       func_SH: in std_logic_vector(func_SH_width-1 downto 0);
       func_SH_TC : in std_logic;
       B_func: out std_logic_vector(func_A_width-1 downto 0));
end DW01_ash_func;

architecture func of DW01_ash_func is
begin
  process (func_DATA_TC, func_SH_TC, func_A,func_SH)
  begin
    if func_DATA_TC = '0' and func_SH_TC = '0' then
      B_func <= std_logic_vector(DWF_ash(unsigned(func_A),unsigned(func_SH)));
    elsif func_DATA_TC = '1' and func_SH_TC = '0' then
      B_func <= std_logic_vector(DWF_ash(signed(func_A),unsigned(func_SH)));
    elsif func_DATA_TC = '1' and func_SH_TC = '1' then
      B_func <= std_logic_vector(DWF_ash(signed(func_A),signed(func_SH)));
    else
      B_func <= std_logic_vector(DWF_ash(unsigned(func_A),signed(func_SH)));
    end if;
  end process;
end func;

