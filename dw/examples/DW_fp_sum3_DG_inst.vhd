library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_fp_sum3_DG_inst is
   generic (
	 inst_sig_width : POSITIVE := 23;
	 inst_exp_width : POSITIVE := 8;
	 inst_ieee_compliance : INTEGER := 0;
	 inst_arch_type : INTEGER := 0
	 );
   port (
	 inst_a : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	 inst_b : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	 inst_c : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	 inst_rnd : in std_logic_vector(2 downto 0);
	 inst_DG_ctrl : in std_logic;
	 z_inst : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	 status_inst : out std_logic_vector(7 downto 0)
	 );
   end DW_fp_sum3_DG_inst;


architecture inst of DW_fp_sum3_DG_inst is

begin

    -- Instance of DW_fp_sum3_DG
    U1 : DW_fp_sum3_DG
	generic map ( sig_width => inst_sig_width, exp_width => inst_exp_width, ieee_compliance => inst_ieee_compliance, arch_type => inst_arch_type )
	port map ( a => inst_a, b => inst_b, c => inst_c, rnd => inst_rnd, DG_ctrl => inst_DG_ctrl, z => z_inst, status => status_inst );


end inst;
