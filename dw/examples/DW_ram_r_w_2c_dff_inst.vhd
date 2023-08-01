library IEEE,WORK,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_ram_r_w_2c_dff_inst is
      generic (
	    inst_width : POSITIVE := 8;
	    inst_depth : POSITIVE := 8;
	    inst_addr_width : NATURAL := 3;  -- set to ceil( log2( depth ) )
	    inst_mem_mode : NATURAL := 5;
	    inst_rst_mode : NATURAL := 1
	    );
      port (
	    inst_clk_w : in std_logic;
	    inst_rst_w_n : in std_logic;
	    inst_init_w_n : in std_logic;
	    inst_en_w_n : in std_logic;
	    inst_addr_w : in std_logic_vector(inst_addr_width-1 downto 0);
	    inst_data_w : in std_logic_vector(inst_width-1 downto 0);
	    inst_clk_r : in std_logic;
	    inst_rst_r_n : in std_logic;
	    inst_init_r_n : in std_logic;
	    inst_en_r_n : in std_logic;
	    inst_addr_r : in std_logic_vector(inst_addr_width-1 downto 0);
	    data_r_a_inst : out std_logic;
	    data_r_inst : out std_logic_vector(inst_width-1 downto 0)
	    );
    end DW_ram_r_w_2c_dff_inst;


architecture inst of DW_ram_r_w_2c_dff_inst is
begin

    -- Instance of DW_ram_r_w_2c_dff
    U1 : DW_ram_r_w_2c_dff
	generic map ( width => inst_width, depth => inst_depth, addr_width => inst_addr_width, mem_mode => inst_mem_mode, rst_mode => inst_rst_mode )
	port map ( clk_w => inst_clk_w, rst_w_n => inst_rst_w_n, init_w_n => inst_init_w_n, en_w_n => inst_en_w_n, addr_w => inst_addr_w, data_w => inst_data_w, clk_r => inst_clk_r, rst_r_n => inst_rst_r_n, init_r_n => inst_init_r_n, en_r_n => inst_en_r_n, addr_r => inst_addr_r, data_r_a => data_r_a_inst, data_r => data_r_inst );

end inst;

-- pragma translate_off
configuration DW_ram_r_w_2s_dff_inst_cfg_inst of DW_ram_r_w_2s_dff_inst is
  for inst
    end for; -- inst
  end DW_ram_r_w_2s_dff_inst_cfg_inst;
-- pragma translate_on
