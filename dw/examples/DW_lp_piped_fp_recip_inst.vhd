library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_lp_piped_fp_recip_inst is
      generic (
	    inst_sig_width : POSITIVE := 23;
	    inst_exp_width : POSITIVE := 8;
	    inst_ieee_compliance : INTEGER := 0;
	    inst_faithful_round : INTEGER := 0;
	    inst_op_iso_mode : NATURAL := 0;
	    inst_id_width : POSITIVE := 8;
	    inst_in_reg : NATURAL := 0;
	    inst_stages : POSITIVE := 4;
	    inst_out_reg : NATURAL := 0;
	    inst_no_pm : NATURAL := 1;
	    inst_rst_mode : NATURAL := 0
	    );
      port (
	    inst_clk : in std_logic;
	    inst_rst_n : in std_logic;
	    inst_a : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	    inst_rnd : in std_logic_vector(2 downto 0);
	    z_inst : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
	    status_inst : out std_logic_vector(7 downto 0);
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
    end DW_lp_piped_fp_recip_inst;


architecture inst of DW_lp_piped_fp_recip_inst is

    component DW_lp_piped_fp_recip
      generic (
	    sig_width : POSITIVE := 23;
	    exp_width : POSITIVE := 8;
	    ieee_compliance : INTEGER := 0;
	    faithful_round : INTEGER := 0;
	    op_iso_mode : NATURAL := 0;
	    id_width : POSITIVE := 8;
	    in_reg : NATURAL := 0;
	    stages : POSITIVE := 4;
	    out_reg : NATURAL := 0;
	    no_pm : NATURAL := 0;
	    rst_mode : NATURAL := 0
	    );
      port (
	    clk : in std_logic;
	    rst_n : in std_logic;
	    a : in std_logic_vector(sig_width+exp_width downto 0);
	    rnd : in std_logic_vector(2 downto 0);
	    z : out std_logic_vector(sig_width+exp_width downto 0);
	    status : out std_logic_vector(7 downto 0);
	    launch : in std_logic;
	    launch_id : in std_logic_vector(id_width-1 downto 0);
	    pipe_full : out std_logic;
	    pipe_ovf : out std_logic;
	    accept_n : in std_logic;
	    arrive : out std_logic;
	    arrive_id : out std_logic_vector(id_width-1 downto 0);
	    push_out_n : out std_logic;
	    pipe_census : out std_logic_vector(bit_width(maximum(1,in_reg+(stages-1)+out_reg)+1)-1 downto 0)
	    );
    end component;

begin

    -- Instance of DW_lp_piped_fp_recip
    U1 : DW_lp_piped_fp_recip
	generic map ( sig_width => inst_sig_width,
             exp_width => inst_exp_width,
             ieee_compliance => inst_ieee_compliance,
             faithful_round => inst_faithful_round,
             op_iso_mode => inst_op_iso_mode,
             id_width => inst_id_width,
             in_reg => inst_in_reg,
             stages => inst_stages,
             out_reg => inst_out_reg,
             no_pm => inst_no_pm,
             rst_mode => inst_rst_mode )
	port map ( clk => inst_clk,
             rst_n => inst_rst_n,
             a => inst_a,
             rnd => inst_rnd,
             z => z_inst,
             status => status_inst,
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
