library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW03_bictr_decode_inst is
  generic (inst_width : POSITIVE := 8);
  port (inst_data      : in std_logic_vector(inst_width-1 downto 0);
        inst_up_dn     : in std_logic;
        inst_load      : in std_logic;
        inst_cen       : in std_logic;
        inst_clk       : in std_logic;
        inst_reset     : in std_logic;
        count_dec_inst : out std_logic_vector(2**inst_width-1 downto 0);
        tercnt_inst    : out std_logic);
end DW03_bictr_decode_inst;

architecture inst of DW03_bictr_decode_inst is
begin

  -- Instance of DW03_bictr_decode
  U1 : DW03_bictr_decode
    generic map ( width => inst_width )
    port map ( data => inst_data, up_dn => inst_up_dn, 
              load => inst_load, cen => inst_cen, clk => inst_clk, 
              reset => inst_reset, count_dec => count_dec_inst, 
              tercnt => tercnt_inst );
end inst;

-- pragma translate_off
configuration DW03_bictr_decode_inst_cfg_inst of DW03_bictr_decode_inst is
  for inst
  end for; -- inst
end DW03_bictr_decode_inst_cfg_inst;
-- pragma translate_on
