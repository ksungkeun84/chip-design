library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_lp_cntr_up_df_inst is
      generic (
	    inst_width : POSITIVE := 8;
	    inst_rst_mode : NATURAL := 0;
	    inst_reg_trmcnt : NATURAL := 0
	    );
      port (
	    inst_clk : in std_logic;
	    inst_rst_n : in std_logic;
	    inst_enable : in std_logic;
	    inst_ld_n : in std_logic;
	    inst_ld_count : in std_logic_vector(inst_width-1 downto 0);
	    inst_term_val : in std_logic_vector(inst_width-1 downto 0);
	    count_inst : out std_logic_vector(inst_width-1 downto 0);
	    term_count_n_inst : out std_logic
	    );
    end DW_lp_cntr_up_df_inst;


architecture inst of DW_lp_cntr_up_df_inst is

begin

    -- Instance of DW_lp_cntr_up_df
    U1 : DW_lp_cntr_up_df
	generic map (	width => inst_width,
			rst_mode => inst_rst_mode,
			reg_trmcnt => inst_reg_trmcnt )

	port map ( clk => inst_clk, rst_n => inst_rst_n,
		   enable => inst_enable, ld_n => inst_ld_n,
		   ld_count => inst_ld_count, term_val => inst_term_val,
		   count => count_inst, term_count_n => term_count_n_inst );

end inst;
