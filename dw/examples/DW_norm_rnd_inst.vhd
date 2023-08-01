library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_norm_rnd_inst is
      generic (
	    inst_a_width : POSITIVE := 16;
	    inst_srch_wind : POSITIVE := 4;
	    inst_exp_width : POSITIVE := 4;
	    inst_b_width : POSITIVE := 10
	    );
      port (
	    inst_a_mag : in std_logic_vector(inst_a_width-1 downto 0);
	    inst_pos_offset : in std_logic_vector(inst_exp_width-1 downto 0);
	    inst_sticky_bit : in std_logic;
	    inst_a_sign : in std_logic;
	    inst_rnd_mode : in std_logic_vector(2 downto 0);
	    pos_err_inst : out std_logic;
	    no_detect_inst : out std_logic;
	    b_inst : out std_logic_vector(inst_b_width-1 downto 0);
	    pos_inst : out std_logic_vector(inst_exp_width-1 downto 0)
	    );
    end DW_norm_rnd_inst;


architecture inst of DW_norm_rnd_inst is

begin

    -- Instance of DW_norm_rnd
    U1 : DW_norm_rnd
	generic map ( a_width => inst_a_width, srch_wind => inst_srch_wind, exp_width => inst_exp_width, b_width => inst_b_width )
	port map ( a_mag => inst_a_mag, pos_offset => inst_pos_offset, sticky_bit => inst_sticky_bit, a_sign => inst_a_sign, rnd_mode => inst_rnd_mode, pos_err => pos_err_inst, no_detect => no_detect_inst, b => b_inst, pos => pos_inst );


end inst;
