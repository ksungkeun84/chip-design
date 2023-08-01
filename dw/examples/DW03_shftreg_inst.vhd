library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW03_shftreg_inst is
  generic ( inst_length : NATURAL := 4 );
  port ( inst_clk     : in std_logic;
         inst_s_in    : in std_logic;
         inst_p_in    : in std_logic_vector(inst_length-1 downto 0);
         inst_shift_n : in std_logic;
         inst_load_n  : in std_logic;
         p_out_inst   : out std_logic_vector(inst_length-1 downto 0) );
end DW03_shftreg_inst;

architecture inst of DW03_shftreg_inst is
begin

  -- Instance of DW03_shftreg
  U1 : DW03_shftreg
    generic map ( length => inst_length )
    port map ( clk => inst_clk,   s_in => inst_s_in,   p_in => inst_p_in,
               shift_n => inst_shift_n,    load_n => inst_load_n, 
               p_out => p_out_inst );
end inst;

-- pragma translate_off
configuration DW03_shftreg_inst_cfg_inst of DW03_shftreg_inst is
  for inst
  end for; -- inst
end DW03_shftreg_inst_cfg_inst;
-- pragma translate_on

