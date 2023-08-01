library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_lza_inst is
      generic (
	    inst_width : NATURAL := 7
	    );
      port (
	    inst_a : in std_logic_vector(inst_width-1 downto 0);
	    inst_b : in std_logic_vector(inst_width-1 downto 0);
	    count_inst : out std_logic_vector(bit_width(inst_width)-1 downto 0)
	    );
    end DW_lza_inst;


architecture inst of DW_lza_inst is

begin

    -- Instance of DW_lza
    U1 : DW_lza
	generic map ( width => inst_width )
	port map ( a => inst_a, 
	           b => inst_b, 
		   count => count_inst );


end inst;
