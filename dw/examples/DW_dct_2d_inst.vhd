library IEEE,DWARE,WORK;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_dct_2d_inst is
  generic (
    	inst_bpp : NATURAL := 8;
    	inst_n : NATURAL := 8;
    	inst_reg_out : NATURAL := 0;
    	inst_tc_mode : NATURAL := 0;
    	inst_rt_mode : NATURAL := 1;
    	inst_idct_mode : NATURAL := 0;
    	inst_co_a : NATURAL := 23170;
    	inst_co_b : NATURAL := 32138;
    	inst_co_c : NATURAL := 30274;
    	inst_co_d : NATURAL := 27245;
    	inst_co_e : NATURAL := 18205;
    	inst_co_f : NATURAL := 12541;
    	inst_co_g : NATURAL := 6393;
    	inst_co_h : NATURAL := 35355;
    	inst_co_i : NATURAL := 49039;
    	inst_co_j : NATURAL := 46194;
    	inst_co_k : NATURAL := 41573;
    	inst_co_l : NATURAL := 27779;
    	inst_co_m : NATURAL := 19134;
    	inst_co_n : NATURAL := 9755;
    	inst_co_o : NATURAL := 35355;
    	inst_co_p : NATURAL := 49039
    	);
  port (
    	inst_clk : in std_logic;
    	inst_rst_n : in std_logic;
    	inst_init_n : in std_logic;
    	inst_enable : in std_logic;
    	inst_start : in std_logic;
    	inst_dct_rd_data : in std_logic_vector(inst_bpp+(inst_n/2*inst_idct_mode)-1 downto 0);
    	inst_tp_rd_data : in std_logic_vector(inst_bpp/2+inst_bpp+3+((1-inst_tc_mode)*(1-inst_idct_mode)) downto 0);
    	tp_rd_add_inst : out std_logic_vector(bit_width(inst_n*inst_n)-1 downto 0);
    	tp_wr_add_inst : out std_logic_vector(bit_width(inst_n*inst_n)-1 downto 0);
    	tp_wr_data_inst : out std_logic_vector(inst_bpp/2+inst_bpp+3+((1-inst_tc_mode)*(1-inst_idct_mode)) downto 0);
    	tp_wr_n_inst : out std_logic;
    	dct_rd_add_inst : out std_logic_vector(bit_width(inst_n*inst_n)-1 downto 0);
    	dct_wr_add_inst : out std_logic_vector(bit_width(inst_n*inst_n)-1 downto 0);
    	dct_wr_n_inst : out std_logic;
    	done_inst : out std_logic;
    	ready_inst : out std_logic;
    	dct_wr_data_inst : out std_logic_vector(inst_bpp-1+(inst_n/2*(1-inst_idct_mode)) downto 0)
    	);
    end DW_dct_2d_inst;


architecture inst of DW_dct_2d_inst is

    component DW_dct_2d
      generic (
	    bpp : NATURAL := 8;
	    n   : NATURAL := 8;
	    reg_out : NATURAL := 0;
	    tc_mode : NATURAL := 0;
	    rt_mode : NATURAL := 1;
	    idct_mode : NATURAL := 0;
	    co_a : NATURAL := 23170;
	    co_b : NATURAL := 32138;
	    co_c : NATURAL := 30274;
	    co_d : NATURAL := 27245;
	    co_e : NATURAL := 18205;
	    co_f : NATURAL := 12541;
	    co_g : NATURAL := 6393;
	    co_h : NATURAL := 35355;
	    co_i : NATURAL := 49039;
	    co_j : NATURAL := 46194;
	    co_k : NATURAL := 41573;
	    co_l : NATURAL := 27779;
	    co_m : NATURAL := 19134;
	    co_n : NATURAL := 9755;
	    co_o : NATURAL := 35355;
	    co_p : NATURAL := 49039 );
      port (clk    : in std_logic;
	    rst_n  : in std_logic;
	    init_n : in std_logic;
	    enable : in std_logic;
	    start  : in std_logic;
	    dct_rd_data : in std_logic_vector(bpp+(n/2*idct_mode)-1 downto 0);
	    tp_rd_data  : in std_logic_vector(bpp/2+bpp+3+((1-tc_mode)*(1-idct_mode)) downto 0);
	    tp_rd_add : out std_logic_vector(bit_width(n*n)-1 downto 0);
	    tp_wr_add : out std_logic_vector(bit_width(n*n)-1 downto 0);
	    tp_wr_data : out std_logic_vector(bpp/2+bpp+3+((1-tc_mode)*(1-idct_mode)) downto 0);
	    tp_wr_n : out std_logic;
	    dct_rd_add : out std_logic_vector(bit_width(n*n)-1 downto 0);
	    dct_wr_add : out std_logic_vector(bit_width(n*n)-1 downto 0);
	    dct_wr_n : out std_logic;
	    done : out std_logic;
	    ready : out std_logic;
	    dct_wr_data : out std_logic_vector(bpp-1+(n/2*(1-idct_mode)) downto 0)
	    );
    end component;

begin

    -- Instance of DW_dct_2d
    U1 : DW_dct_2d
	generic map ( bpp => inst_bpp,
                     n => inst_n,
                     reg_out => inst_reg_out,
                     tc_mode => inst_tc_mode,
                     rt_mode => inst_rt_mode,
                     idct_mode => inst_idct_mode,
                     co_a => inst_co_a,
                     co_b => inst_co_b,
                     co_c => inst_co_c,
                     co_d => inst_co_d,
                     co_e => inst_co_e,
                     co_f => inst_co_f,
                     co_g => inst_co_g,
                     co_h => inst_co_h,
                     co_i => inst_co_i,
                     co_j => inst_co_j,
                     co_k => inst_co_k,
                     co_l => inst_co_l,
                     co_m => inst_co_m,
                     co_n => inst_co_n,
                     co_o => inst_co_o,
                     co_p => inst_co_p )
	port map ( clk => inst_clk,
                     rst_n => inst_rst_n,
                     init_n => inst_init_n,
                     enable => inst_enable,
                     start => inst_start,
                     dct_rd_data => inst_dct_rd_data,
                     tp_rd_data => inst_tp_rd_data,
                     tp_rd_add => tp_rd_add_inst,
                     tp_wr_add => tp_wr_add_inst,
                     tp_wr_data => tp_wr_data_inst,
                     tp_wr_n => tp_wr_n_inst,
                     dct_rd_add => dct_rd_add_inst,
                     dct_wr_add => dct_wr_add_inst,
                     dct_wr_n => dct_wr_n_inst,
                     done => done_inst,
                     ready => ready_inst,
                     dct_wr_data => dct_wr_data_inst );

end inst;
