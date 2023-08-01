library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_norm_inst is
      generic (
	    inst_a_width : POSITIVE := 8;
	    inst_srch_wind : POSITIVE := 8;
	    inst_exp_width : POSITIVE := 4
	    );
      port (
	    inst_a : in std_logic_vector(inst_a_width-1 downto 0);
	    inst_exp_offset : in std_logic_vector(inst_exp_width-1 downto 0);
	    no_detect_inst : out std_logic;
	    ovfl_inst : out std_logic;
	    b_inst : out std_logic_vector(inst_a_width-1 downto 0);
	    exp_adj_inst : out std_logic_vector(inst_exp_width-1 downto 0)
	    );
    end DW_norm_inst;


architecture inst of DW_norm_inst is

begin

    -- Instance of DW_norm
    U1 : DW_norm
	generic map ( a_width => inst_a_width, srch_wind => inst_srch_wind, exp_width => inst_exp_width )
	port map ( a => inst_a, exp_offset => inst_exp_offset, no_detect => no_detect_inst, ovfl => ovfl_inst, b => b_inst, exp_adj => exp_adj_inst );


end inst;

