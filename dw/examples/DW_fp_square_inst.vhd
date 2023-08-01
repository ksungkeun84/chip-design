library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;
-- If using numeric types from std_logic_arith package,
-- comment the preceding line and uncomment the following line:
-- use DWARE.DW_Foundation_comp_arith.all;

entity DW_fp_square_inst is
  generic (
    inst_sig_width       : POSITIVE := 23;
    inst_exp_width       : POSITIVE := 8;
    inst_ieee_compliance : INTEGER := 0
  );
  port (
    inst_a      : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
    inst_rnd    : in std_logic_vector(2 downto 0);
    z_inst      : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
    status_inst : out std_logic_vector(7 downto 0)
  );
end DW_fp_square_inst;


architecture inst of DW_fp_square_inst is

begin

  -- Instance of DW_fp_square
  U1 : DW_fp_square
  generic map (
	sig_width => inst_sig_width,
	exp_width => inst_exp_width,
	ieee_compliance => inst_ieee_compliance
  )
  port map (
	a => inst_a,
	rnd => inst_rnd,
	z => z_inst,
	status => status_inst
  );

end inst;

-- pragma translate_off
configuration DW_fp_square_inst_cfg_inst of DW_fp_square_inst is
  for inst
  end for;
end DW_fp_square_inst_cfg_inst;
-- pragma translate_on
