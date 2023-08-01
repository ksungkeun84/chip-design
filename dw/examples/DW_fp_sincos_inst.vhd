library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_fp_sincos_inst is
    generic (
	  inst_sig_width : POSITIVE := 23;
	  inst_exp_width : POSITIVE := 8;
	  inst_ieee_compliance : INTEGER := 0;
	  inst_pi_multiple : INTEGER := 1;
	  inst_arch : INTEGER := 0;
	  inst_err_range : INTEGER := 1
	  );
    port (
	  inst_a : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	  inst_sin_cos : in std_logic;
	  z_inst : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	  status_inst : out std_logic_vector(7 downto 0)
	  );
end DW_fp_sincos_inst;


architecture inst of DW_fp_sincos_inst is

begin

    -- Instance of DW_fp_sincos
    U1 : DW_fp_sincos
	generic map (
		sig_width => inst_sig_width,
		exp_width => inst_exp_width,
		ieee_compliance => inst_ieee_compliance,
		pi_multiple => inst_pi_multiple,
		arch => inst_arch,
		err_range => inst_err_range
		)
	port map (
		a => inst_a,
		sin_cos => inst_sin_cos,
		z => z_inst,
		status => status_inst
		);


end inst;

-- pragma translate_off
configuration DW_fp_sincos_inst_cfg_inst of DW_fp_sincos_inst is
for inst
end for;
end DW_fp_sincos_inst_cfg_inst;
-- pragma translate_on

