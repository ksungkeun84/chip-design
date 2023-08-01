library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_piped_mac_inst is
      generic (
	    inst_a_width : POSITIVE := 8;
	    inst_b_width : POSITIVE := 8;
	    inst_acc_width : POSITIVE := 16;
	    inst_tc : NATURAL := 0;
	    inst_pipe_reg : NATURAL := 0;
	    inst_id_width : POSITIVE := 1;
	    inst_no_pm : NATURAL := 0;
	    inst_op_iso_mode : NATURAL := 0
	    );
      port (
	    inst_clk : in std_logic;
	    inst_rst_n : in std_logic;
	    inst_init_n : in std_logic;
	    inst_clr_acc_n : in std_logic;
	    inst_a : in std_logic_vector(inst_a_width-1 downto 0);
	    inst_b : in std_logic_vector(inst_b_width-1 downto 0);
	    acc_inst : out std_logic_vector(inst_acc_width-1 downto 0);
	    inst_launch : in std_logic;
	    inst_launch_id : in std_logic_vector(inst_id_width-1 downto 0);
	    pipe_full_inst : out std_logic;
	    pipe_ovf_inst : out std_logic;
	    inst_accept_n : in std_logic;
	    arrive_inst : out std_logic;
	    arrive_id_inst : out std_logic_vector(inst_id_width-1 downto 0);
	    push_out_n_inst : out std_logic;
	    pipe_census_inst : out std_logic_vector(2 downto 0)
	    );
    end DW_piped_mac_inst;


architecture inst of DW_piped_mac_inst is

begin

    -- Instance of DW_piped_mac
    U1 : DW_piped_mac
	generic map ( a_width => inst_a_width, 
			b_width => inst_b_width, 
		  	acc_width => inst_acc_width, 
		  	tc => inst_tc, 
		  	pipe_reg => inst_pipe_reg, 
		  	id_width => inst_id_width,
		  	no_pm => inst_no_pm,
		  	op_iso_mode => inst_op_iso_mode )

	port map ( clk => inst_clk, 
                   rst_n => inst_rst_n, 
                   init_n => inst_init_n, 
                   clr_acc_n => inst_clr_acc_n, 
                   a => inst_a, 
                   b => inst_b, 
                   acc => acc_inst, 
                   launch => inst_launch, 
                   launch_id => inst_launch_id, 
                   pipe_full => pipe_full_inst, 
                   pipe_ovf => pipe_ovf_inst, 
                   accept_n => inst_accept_n, 
                   arrive => arrive_inst, 
                   arrive_id => arrive_id_inst, 
                   push_out_n => push_out_n_inst, 
                   pipe_census => pipe_census_inst );
end inst;

-- Configuration for use with a VHDL simulator
-- pragma translate_off
library DW03;
configuration DW_piped_mac_inst_cfg_inst of DW_piped_mac_inst is
  for inst
  end for; -- inst
end DW_piped_mac_inst_cfg_inst;
-- pragma translate_on
