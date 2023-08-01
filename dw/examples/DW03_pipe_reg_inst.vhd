library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW03_pipe_reg_inst is
  generic ( inst_depth : INTEGER := 8;
            inst_width : INTEGER := 8 );
  port ( inst_A   : in std_logic_vector(inst_width-1 downto 0);
         inst_clk : in std_logic;
         B_inst   : out std_logic_vector(inst_width-1 downto 0) );
end DW03_pipe_reg_inst;

architecture inst of DW03_pipe_reg_inst is
begin

  -- Instance of DW03_pipe_reg
 U1 : DW03_pipe_reg
    generic map ( depth => inst_depth, width => inst_width )
    port map ( A => inst_A, clk => inst_clk, B => B_inst );
end inst;

-- pragma translate_off
configuration DW03_pipe_reg_inst_cfg_inst of DW03_pipe_reg_inst is
  for inst
  end for; -- inst
end DW03_pipe_reg_inst_cfg_inst;
-- pragma translate_on

