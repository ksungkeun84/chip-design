library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.dw_foundation_comp.all;

entity DW_rbsh_inst is
      generic (
	    inst_A_width : POSITIVE := 8;
	    inst_SH_width : POSITIVE := 3
	    );
      port (
	    inst_A : in std_logic_vector(inst_A_width-1 downto 0);
	    inst_SH : in std_logic_vector(inst_SH_width-1 downto 0);
	    inst_SH_TC : in std_logic;
	    B_inst : out std_logic_vector(inst_A_width-1 downto 0)
	    );
    end DW_rbsh_inst;

architecture inst of DW_rbsh_inst is

begin

    -- Instance of DW_rbsh
    U1 : DW_rbsh
	generic map (
		A_width => inst_A_width,
		SH_width => inst_SH_width
		)
	port map (
		A => inst_A,
		SH => inst_SH,
		SH_TC => inst_SH_TC,
		B => B_inst
		);

end inst;
