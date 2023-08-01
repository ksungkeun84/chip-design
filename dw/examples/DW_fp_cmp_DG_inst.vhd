library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_fp_cmp_DG_inst is
   generic (
	 inst_sig_width : POSITIVE := 23;
	  inst_exp_width : POSITIVE := 8;
	  inst_ieee_compliance : INTEGER := 0
	  );
    port (
	  inst_a : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	  inst_b : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	  inst_zctr : in std_logic;
	  inst_DG_ctrl : in std_logic;
	  aeqb_inst : out std_logic;
	  altb_inst : out std_logic;
	  agtb_inst : out std_logic;
      unordered_inst : out std_logic;
    z0_inst : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
    z1_inst : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	  status0_inst : out std_logic_vector(7 downto 0);
	  status1_inst : out std_logic_vector(7 downto 0)
	  );
    end DW_fp_cmp_DG_inst;


architecture inst of DW_fp_cmp_DG_inst is

begin

    -- Instance of DW_fp_cmp_DG
    U1 : DW_fp_cmp_DG
	generic map ( sig_width => inst_sig_width, exp_width => inst_exp_width, ieee_compliance => inst_ieee_compliance )
	port map ( a => inst_a, b => inst_b, zctr => inst_zctr, DG_ctrl => inst_DG_ctrl, aeqb => aeqb_inst, altb => altb_inst, agtb => agtb_inst, unordered => unordered_inst, z0 => z0_inst, z1 => z1_inst, status0 => status0_inst, status1 => status1_inst );


end inst;
