library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_ram_rw_s_lat_inst is
  generic (inst_data_width : INTEGER := 8;   inst_depth : INTEGER := 8 );
  port (inst_clk     : in std_logic;
        inst_cs_n    : in std_logic;
        inst_wr_n    : in std_logic;
        inst_rw_addr : in std_logic_vector(bit_width(inst_depth)-1 downto 0);
        inst_data_in : in std_logic_vector(inst_data_width-1 downto 0);
        data_out_inst: out std_logic_vector(inst_data_width-1 downto 0) );
end DW_ram_rw_s_lat_inst;

architecture inst of DW_ram_rw_s_lat_inst is
begin

  -- Instance of DW_ram_rw_s_lat
  U1 : DW_ram_rw_s_lat
    generic map (data_width => inst_data_width,   depth => inst_depth )
    port map (clk => inst_clk,   cs_n => inst_cs_n,   wr_n => inst_wr_n,
              rw_addr => inst_rw_addr,   data_in => inst_data_in, 
              data_out => data_out_inst );
end inst;

-- pragma translate_off
configuration DW_ram_rw_s_lat_inst_cfg_inst of DW_ram_rw_s_lat_inst is
  for inst
  end for; -- inst
end DW_ram_rw_s_lat_inst_cfg_inst;
-- pragma translate_on

