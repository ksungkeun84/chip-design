library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW01_satrnd_inst is
  generic ( inst_width   : POSITIVE := 8;
            inst_msb_out : NATURAL  := 7;
            inst_lsb_out : NATURAL  := 1 );
  port ( inst_din  : in std_logic_vector(inst_width-1 downto 0);
         inst_tc   : in std_logic;
         inst_sat  : in std_logic;
         inst_rnd  : in std_logic;
         ov_inst   : out std_logic;
         dout_inst : out std_logic_vector(inst_msb_out-inst_lsb_out downto 0)
       );
end DW01_satrnd_inst;

architecture inst of DW01_satrnd_inst is
begin

  -- Instance of DW01_satrnd
  U1 : DW01_satrnd
    generic map ( width => inst_width,   msb_out => inst_msb_out, 
                  lsb_out => inst_lsb_out )
    port map ( din => inst_din,   tc => inst_tc,   sat => inst_sat, 
               rnd => inst_rnd,   ov => ov_inst,   dout => dout_inst );
end inst;

-- pragma translate_off
configuration DW01_satrnd_inst_cfg_inst of DW01_satrnd_inst is
  for inst
  end for; -- inst
end DW01_satrnd_inst_cfg_inst;
-- pragma translate_on

