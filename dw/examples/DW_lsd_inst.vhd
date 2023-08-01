library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_lsd_inst is
      generic (
	    inst_a_width : POSITIVE := 8
	    );
      port (
	    inst_a : in std_logic_vector(inst_a_width-1 downto 0);
	    enc_inst : out std_logic_vector(bit_width(inst_a_width)-1 downto 0);
	    dec_inst : out std_logic_vector(inst_a_width-1 downto 0)
	    );
    end DW_lsd_inst;


architecture inst of DW_lsd_inst is

begin

    -- Instance of DW_lsd
    U1 : DW_lsd
	generic map (
		a_width => inst_a_width
		)
	port map (
		a => inst_a,
		enc => enc_inst,
		dec => dec_inst
		);


end inst;
