library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_fp_recip_inst is
      generic (
	    inst_sig_width : POSITIVE := 23;
	    inst_exp_width : POSITIVE := 8;
	    inst_ieee_compliance : INTEGER := 0;
	    inst_faithful_round : INTEGER := 0
	    );
      port (
	    inst_a : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	    inst_rnd : in std_logic_vector(2 downto 0);
	    z_inst : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	    status_inst : out std_logic_vector(7 downto 0)
	    );
    end DW_fp_recip_inst;


architecture inst of DW_fp_recip_inst is

begin

    -- Instance of DW_fp_recip
    U1 : DW_fp_recip
	generic map (
		sig_width => inst_sig_width,
		exp_width => inst_exp_width,
		ieee_compliance => inst_ieee_compliance,
		faithful_round => inst_faithful_round
		)
	port map (
		a => inst_a,
		rnd => inst_rnd,
		z => z_inst,
		status => status_inst
		);


end inst;
