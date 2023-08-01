--------------------------------------------------------------------------------
--
--  This example uses an instance of DW_lp_pipe_mgr along with an instance
--  of DW_pl_reg to pipeline an unsigned multiplication operation.
--
--------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DWARE.DW_Foundation_comp.all;
use DWARE.DWpackages.all;

entity DW_lp_pipe_mgr_inst is
      generic (
	    inst_a_width : POSITIVE := 8;
	    inst_b_width : POSITIVE := 8;
	    inst_id_width : POSITIVE := 8;
	    inst_stages : POSITIVE := 4
	    );
      port (
	    inst_clk : in std_logic;
	    inst_rst_n : in std_logic;

	    -- upstream (input) status
	    pipe_full_inst : out std_logic;
	    pipe_ovf_inst : out std_logic;

	    -- upstream (input) interface
	    -- (request, ID & data)
	    inst_launch : in std_logic;
	    inst_launch_id : in std_logic_vector(inst_id_width-1 downto 0);
	    inst_a : in std_logic_vector(inst_a_width-1 downto 0);
	    inst_b : in std_logic_vector(inst_b_width-1 downto 0);

	    -- downstream (output) interface
	    -- (output indication, ID * data)
	    arrive_inst : out std_logic;
	    arrive_id_inst : out std_logic_vector(inst_id_width-1 downto 0);
	    product_inst : out std_logic_vector(inst_a_width+inst_b_width-1 downto 0);

	    -- downstream (output) FIFO flow control
	    inst_accept_n : in std_logic;
	    push_out_n_inst : out std_logic;

	    -- pipe content status
	    pipe_census_inst : out std_logic_vector(bit_width(inst_stages+1)-1 downto 0)
	    );
    end DW_lp_pipe_mgr_inst;


architecture inst of DW_lp_pipe_mgr_inst is

-- Embedded script causes registers to be balanced
--
-- synopsys dc_script_begin
-- set_optimize_registers "true"
-- synopsys dc_script_end


-- the UNSIGNED product
signal prod_int : UNSIGNED(inst_a_width+inst_b_width-1 downto 0);

-- copy of product that has been cast to std_logic_vector type
signal a_times_b : std_logic_vector(inst_a_width+inst_b_width-1 downto 0);

-- DW_lp_pipe_mgr will conrtol register enables to pipe
-- via a bus of enables (one per register stage)
--
signal local_enables : std_logic_vector(inst_stages-1 downto 0);

signal tie_high : std_logic;

begin

    tie_high <= '1';


    -- operation to be pipelined is just "a * b"
    --
    prod_int <= UNSIGNED(inst_a) * UNSIGNED(inst_b);

    a_times_b <= STD_LOGIC_VECTOR(prod_int);

    -- Instance of DW_lp_pipe_mgr
    U1 : DW_lp_pipe_mgr
	generic map (
		stages => inst_stages,
		id_width => inst_id_width
		)
	port map (
		clk => inst_clk,
		rst_n => inst_rst_n,
		init_n => tie_high,
		launch => inst_launch,
		launch_id => inst_launch_id,
		pipe_full => pipe_full_inst,
		pipe_ovf => pipe_ovf_inst,
		pipe_en_bus => local_enables,
		accept_n => inst_accept_n,
		arrive => arrive_inst,
		arrive_id => arrive_id_inst,
		push_out_n => push_out_n_inst,
		pipe_census => pipe_census_inst
		);

    -- An instance of DW_pl_reg is used to get the data registers
    -- in the pipe (initially stacked all at the output - but DC
    -- will balance them)  Note that DW_pl_reg will ungroup itself
    -- automatically so that its registers will be free to be
    -- balanced into the datapath logic.
    --
    U2 : DW_pl_reg
	generic map (
		width => inst_a_width+inst_b_width,
		in_reg => 0,
		stages => inst_stages,
		out_reg => 1,
		rst_mode => 0
		)
	port map (
		clk => inst_clk,
		rst_n => inst_rst_n,
		enable => local_enables,
		data_in => a_times_b,
		data_out => product_inst
		);

end inst;
