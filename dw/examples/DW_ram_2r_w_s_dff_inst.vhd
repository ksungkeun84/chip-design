library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_ram_2r_w_s_dff_inst is
  generic (inst_data_width : INTEGER := 8;
           inst_depth : INTEGER := 8;
           inst_rst_mode : INTEGER := 0 );
  port (inst_clk      : in std_logic;
        inst_rst_n    : in std_logic;
        inst_cs_n     : in std_logic;
        inst_wr_n     : in std_logic;
        inst_rd1_addr : in std_logic_vector(bit_width(inst_depth)-1 
                                                                 downto 0);
        inst_rd2_addr : in std_logic_vector(bit_width(inst_depth)-1 
                                                                 downto 0);
        inst_wr_addr : in std_logic_vector(bit_width(inst_depth)-1 downto 0);
        inst_data_in : in std_logic_vector(inst_data_width-1 downto 0);
        data_rd1_out_inst : out std_logic_vector(inst_data_width-1 downto 0);
        data_rd2_out_inst : out std_logic_vector(inst_data_width-1 downto 0)
        );
end DW_ram_2r_w_s_dff_inst;

architecture inst of DW_ram_2r_w_s_dff_inst is
begin

  -- Instance of DW_ram_2r_w_s_dff
  U1 : DW_ram_2r_w_s_dff
    generic map (data_width => inst_data_width,   depth => inst_depth,
                 rst_mode => inst_rst_mode )
    port map (clk => inst_clk,   rst_n => inst_rst_n,   cs_n => inst_cs_n,
              wr_n => inst_wr_n,   rd1_addr => inst_rd1_addr, 
              rd2_addr => inst_rd2_addr,   wr_addr => inst_wr_addr, 
              data_in => inst_data_in,   data_rd1_out => data_rd1_out_inst,
              data_rd2_out => data_rd2_out_inst );
end inst;

-- pragma translate_off
configuration DW_ram_2r_w_s_dff_inst_cfg_inst of DW_ram_2r_w_s_dff_inst is
  for inst
  end for; -- inst
end DW_ram_2r_w_s_dff_inst_cfg_inst;
-- pragma translate_on

