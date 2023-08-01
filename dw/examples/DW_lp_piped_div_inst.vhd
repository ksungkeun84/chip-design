library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_lp_piped_div_inst is
      generic (
	    inst_a_width : POSITIVE := 8;
	    inst_b_width : POSITIVE := 8;
	    inst_id_width : POSITIVE := 8;
	    inst_in_reg : NATURAL := 0;
	    inst_stages : POSITIVE := 4;
	    inst_out_reg : NATURAL := 0;
	    inst_tc_mode : NATURAL := 0;
	    inst_rst_mode : NATURAL := 0;
	    inst_rem_mode : NATURAL := 1;
	    inst_op_iso_mode : NATURAL := 0
	    );
      port (
	    inst_clk : in std_logic;
	    inst_rst_n : in std_logic;
	    inst_a : in std_logic_vector(inst_a_width-1 downto 0);
	    inst_b : in std_logic_vector(inst_b_width-1 downto 0);
	    quotient_inst : out std_logic_vector(inst_a_width-1 downto 0);
	    remainder_inst : out std_logic_vector(inst_b_width-1 downto 0);
	    div_by_0_inst : out std_logic;
	    inst_launch : in std_logic;
	    inst_launch_id : in std_logic_vector(inst_id_width-1 downto 0);
	    pipe_full_inst : out std_logic;
	    pipe_ovf_inst : out std_logic;
	    inst_accept_n : in std_logic;
	    arrive_inst : out std_logic;
	    arrive_id_inst : out std_logic_vector(inst_id_width-1 downto 0);
	    push_out_n_inst : out std_logic;
	    pipe_census_inst : out std_logic_vector(bit_width(maximum(1,inst_in_reg+(inst_stages-1)+inst_out_reg)+1)-1 downto 0)
	    );
    end DW_lp_piped_div_inst;


architecture inst of DW_lp_piped_div_inst is

begin

    -- Instance of DW_lp_piped_div
    U1 : DW_lp_piped_div
	generic map ( a_width => inst_a_width,
                      b_width => inst_b_width,
                      id_width => inst_id_width,
                      in_reg => inst_in_reg,
                      stages => inst_stages,
                      out_reg => inst_out_reg,
                      tc_mode => inst_tc_mode,
                      rst_mode => inst_rst_mode,
                      rem_mode => inst_rem_mode,
                      op_iso_mode => inst_op_iso_mode )
	port map ( clk => inst_clk,
                   rst_n => inst_rst_n,
                   a => inst_a,
                   b => inst_b,
                   quotient => quotient_inst,
                   remainder => remainder_inst,
                   div_by_0 => div_by_0_inst,
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
