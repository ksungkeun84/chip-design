library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_inv_sqrt_inst is
      generic (
	    inst_a_width : POSITIVE := 8
	    );
      port (
	    inst_a : in std_logic_vector(inst_a_width-1 downto 0);
	    b_inst : out std_logic_vector(inst_a_width-1 downto 0);
	    t_inst : out std_logic
	    );
    end DW_inv_sqrt_inst;


architecture inst of DW_inv_sqrt_inst is

begin

    -- Instance of DW_inv_sqrt
    U1 : DW_inv_sqrt
	generic map ( a_width => inst_a_width )
	port map ( a => inst_a, b => b_inst, t => t_inst );


end inst;
