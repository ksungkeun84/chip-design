library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_div_inst is

  generic ( width    : positive := 8;
            tc_mode  : natural  := 0;
            rem_mode : natural  := 1);
  port ( a           : in  std_logic_vector(width-1 downto 0);
         b           : in  std_logic_vector(width-1 downto 0);
         quotient    : out std_logic_vector(width-1 downto 0);
         remainder   : out std_logic_vector(width-1 downto 0);
         divide_by_0 : out std_logic);
end DW_div_inst;

architecture inst of DW_div_inst is
begin
  -- instance of DW_div
  U1 : DW_div
    generic map ( a_width => width, b_width => width,
                  tc_mode => tc_mode, rem_mode => rem_mode)
    port map ( a => a, b => b,
               quotient => quotient, remainder => remainder,
               divide_by_0 => divide_by_0);
end inst;

-- pragma translate_off
configuration DW_div_inst_cfg_inst of DW_div_inst is
  for inst
  end for;
end DW_div_inst_cfg_inst;
-- pragma translate_on

