library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_sincos_inst is
      generic (
	    inst_A_width : INTEGER := 24;
	    inst_WAVE_width : INTEGER := 25;
	    inst_arch : INTEGER := 0;
	    inst_err_range : INTEGER := 1
	    );
      port (
	    inst_A : in std_logic_vector(inst_A_width-1 downto 0);
	    inst_SIN_COS : in std_logic;
	    WAVE_inst : out std_logic_vector(inst_WAVE_width-1 downto 0)
	    );
    end DW_sincos_inst;


architecture inst of DW_sincos_inst is

begin

    -- Instance of DW_sincos
    U1 : DW_sincos
	generic map (
		A_width => inst_A_width,
		WAVE_width => inst_WAVE_width,
		arch => inst_arch,
		err_range => inst_err_range
		)
	port map (
		A => inst_A,
		SIN_COS => inst_SIN_COS,
		WAVE => WAVE_inst
		);


end inst;
