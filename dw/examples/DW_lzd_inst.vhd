library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;
use DWARE.DWpackages.all;
-- If using numeric_std data types of std_logic_arith, uncomment the 
-- following line:
-- use DWARE.DW_Foundation_arith.all;

entity DW_lzd_inst is
      generic (
	    inst_a_width : POSITIVE := 8
	    );
      port (
	    inst_a : in std_logic_vector(inst_a_width-1 downto 0);
	    dec_inst : out std_logic_vector(inst_a_width-1 downto 0);
	    enc_inst : out std_logic_vector(bit_width(inst_a_width) downto 0)
	    );
    end DW_lzd_inst;


architecture inst of DW_lzd_inst is
begin

    -- Instance of DW_lzd
    U1 : DW_lzd
	generic map ( a_width => inst_a_width )
	port map ( a => inst_a, dec => dec_inst, enc => enc_inst );
end inst;

-- pragma translate_off
configuration DW_lzd_inst_cfg_inst of DW_lzd_inst is
  for inst
  end for; -- inst
end DW_lzd_inst_cfg_inst;
-- pragma translate_on

