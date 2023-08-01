library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation_arith.all;

entity DW_shifter_func is
  generic(func_data_width:integer:=8; func_sh_width : integer := 3);
  port(func_data_in : in std_logic_vector(func_data_width-1 downto 0);
       func_data_tc : in std_logic;
       func_sh      : in std_logic_vector(func_sh_width-1 downto 0);
       func_sh_tc   : in std_logic;
       func_sh_mode : in std_logic;
       data_out_func: out std_logic_vector(func_data_width-1 downto 0) );
end DW_shifter_func;

architecture func of DW_shifter_func is
begin
  process (func_data_tc, func_sh_tc, func_data_in, func_sh, func_sh_mode)
  begin
    if func_DATA_TC = '0' and func_SH_TC = '0' then
      data_out_func <= 
            std_logic_vector(DWF_shifter(unsigned(func_data_in),
                                         unsigned(func_SH), func_sh_mode));
    elsif func_DATA_TC = '1' and func_SH_TC = '0' then
      data_out_func <=
            std_logic_vector(DWF_shifter(signed(func_data_in),
                                         unsigned(func_SH), func_sh_mode) );
    elsif func_DATA_TC = '1' and func_SH_TC = '1' then
      data_out_func <=
            std_logic_vector(DWF_shifter(signed(func_data_in),
                                         signed(func_SH), func_sh_mode) );
    else
      data_out_func <=
            std_logic_vector(DWF_shifter(unsigned(func_data_in),
                                         signed(func_SH), func_sh_mode));
    end if;
  end process;
end func;

