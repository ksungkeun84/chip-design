library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_lp_multifunc_inst is
      generic (
	    inst_op_width : POSITIVE := 24;
	    inst_func_select : POSITIVE := 127
	    );
      port (
	    inst_a : in std_logic_vector(inst_op_width downto 0);
	    inst_func : in std_logic_vector(15 downto 0);
	    z_inst : out std_logic_vector(inst_op_width+1 downto 0);
	    status_inst : out std_logic
	    );
    end DW_lp_multifunc_inst;


architecture inst of DW_lp_multifunc_inst is

begin

    -- Instance of DW_lp_multifunc
    U1 : DW_lp_multifunc
	generic map (
		op_width => inst_op_width,
		func_select => inst_func_select
		)
	port map (
		a => inst_a,
		func => inst_func,
		z => z_inst,
		status => status_inst
		);


end inst;

