library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_lp_fp_multifunc_inst is
      generic (
	    inst_sig_width : INTEGER := 23;
	    inst_exp_width : INTEGER := 8;
	    inst_ieee_compliance : INTEGER := 0;
	    inst_func_select : INTEGER := 127;
	    inst_faithful_round : INTEGER := 1;
	    inst_pi_multiple : INTEGER := 1
	    );
      port (
	    inst_a : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	    inst_func : in std_logic_vector(15 downto 0);
	    inst_rnd : in std_logic_vector(2 downto 0);
	    z_inst : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	    status_inst : out std_logic_vector(7 downto 0)
	    );
    end DW_lp_fp_multifunc_inst;


architecture inst of DW_lp_fp_multifunc_inst is

begin
    -- Instance of DW_lp_fp_multifunc
    U1 : DW_lp_fp_multifunc
	generic map (
		sig_width => inst_sig_width,
		exp_width => inst_exp_width,
		ieee_compliance => inst_ieee_compliance,
		func_select => inst_func_select,
		faithful_round => inst_faithful_round,
		pi_multiple => inst_pi_multiple
		)
	port map (
		a => inst_a,
		func => inst_func,
		rnd => inst_rnd,
		z => z_inst,
		status => status_inst
		);

end inst;
