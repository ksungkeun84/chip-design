library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_decode_en_inst is
      generic (
	    inst_width : NATURAL := 8
	    );
      port (
	    inst_en : in std_logic;
	    inst_a : in std_logic_vector(inst_width-1 downto 0);
	    b_inst : out std_logic_vector(2**inst_width-1 downto 0)
	    );
    end DW_decode_en_inst;


architecture inst of DW_decode_en_inst is

begin

    -- Instance of DW_decode_en
    U1 : DW_decode_en
	generic map (
		width => inst_width
		)
	port map (
		en => inst_en,
		a => inst_a,
		b => b_inst
		);


end inst;

-- pragma translate_off
configuration DW_decode_en_inst_cfg_inst of DW_decode_en_inst is
  for inst
  end for; -- inst
end DW_decode_en_inst_cfg_inst;
-- pragma translate_on
