library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

-- example: instantiation of 4-input minimum/maximum component
entity DW_minmax_inst is
  generic ( wordlength : natural := 8);
  port ( a0, a1, a2, a3 : in  std_logic_vector(wordlength-1 downto 0);
         tc             : in  std_logic;
         max            : in  std_logic;
         val            : out std_logic_vector(wordlength-1 downto 0);
         idx            : out std_logic_vector(1 downto 0));
end DW_minmax_inst;

architecture inst of DW_minmax_inst is
  signal a : std_logic_vector(4*wordlength-1 downto 0);
begin

  -- concatenation of inputs
  a <= a3 & a2 & a1 & a0;
  
  -- instantiation of DW_minmax
  U1 : DW_minmax
    generic map (width => wordlength, num_inputs => 4)
    port map (a => a, tc => tc, min_max => max, value => val, index => idx);
end inst;

-- pragma translate_off
configuration DW_minmax_inst_cfg_inst of DW_minmax_inst is
  for inst
  end for;
end DW_minmax_inst_cfg_inst;
-- pragma translate_on

