library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW04_shad_reg_inst is
  generic ( inst_width        : POSITIVE := 8;
            inst_bld_shad_reg : NATURAL := 1 );
  port ( inst_datain   : in std_logic_vector(inst_width-1 downto 0);
         inst_sys_clk  : in std_logic;
         inst_shad_clk : in std_logic;
         inst_reset    : in std_logic;
         inst_SI       : in std_logic;
         inst_SE       : in std_logic;
         sys_out_inst  : out std_logic_vector(inst_width-1 downto 0);
         shad_out_inst : out std_logic_vector(inst_width-1 downto 0);
         SO_inst       : out std_logic );
end DW04_shad_reg_inst;

architecture inst of DW04_shad_reg_inst is
begin

  --Instance of DW04_shad_reg
  U1 : DW04_shad_reg
    generic map ( width => inst_width,  bld_shad_reg => inst_bld_shad_reg )
    port map ( datain => inst_datain,   sys_clk => inst_sys_clk, 
               shad_clk => inst_shad_clk,   reset => inst_reset, 
               SI => inst_SI,   SE => inst_SE,   sys_out => sys_out_inst,
               shad_out => shad_out_inst,   SO => SO_inst );
end inst;

-- pragma translate_off
configuration DW04_shad_reg_inst_cfg_inst of DW04_shad_reg_inst is
  for inst
  end for; -- inst
end DW04_shad_reg_inst_cfg_inst;
-- pragma translate_on

