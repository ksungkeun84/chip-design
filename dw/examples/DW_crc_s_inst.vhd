library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_foundation_comp.all;

entity DW_crc_s_inst is
  generic (inst_data_width : INTEGER := 16;   inst_poly_size : INTEGER := 16;
           inst_crc_cfg    : INTEGER := 7;    inst_bit_order : INTEGER := 3;
           inst_poly_coef0 : INTEGER := 4129; inst_poly_coef1: INTEGER := 0;
           inst_poly_coef2 : INTEGER := 0;    inst_poly_coef3: INTEGER := 0);
  port (inst_clk        : in std_logic;     inst_rst_n    : in std_logic;
        inst_init_n     : in std_logic;     inst_enable   : in std_logic;
        inst_drain      : in std_logic;     inst_ld_crc_n : in std_logic;
        inst_data_in    : in std_logic_vector(inst_data_width-1 downto 0);
        inst_crc_in     : in std_logic_vector(inst_poly_size-1 downto 0);
        draining_inst   : out std_logic;
        drain_done_inst : out std_logic;
        crc_ok_inst     : out std_logic;
        data_out_inst   : out std_logic_vector(inst_data_width-1 downto 0);
        crc_out_inst    : out std_logic_vector(inst_poly_size-1 downto 0)  );
    end DW_crc_s_inst;

architecture inst of DW_crc_s_inst is
begin

  -- Instance of DW_crc_s
  U1 : DW_crc_s
    generic map (data_width => inst_data_width,  poly_size => inst_poly_size,
                 crc_cfg => inst_crc_cfg,   bit_order => inst_bit_order,
                 poly_coef0 => inst_poly_coef0, 
                 poly_coef1 => inst_poly_coef1,
                 poly_coef2 => inst_poly_coef2,   
                 poly_coef3 => inst_poly_coef3 )
    port map (clk => inst_clk,   rst_n => inst_rst_n,  init_n => inst_init_n,
              enable => inst_enable,   drain => inst_drain, 
              ld_crc_n => inst_ld_crc_n,   data_in => inst_data_in, 
              crc_in => inst_crc_in,   draining => draining_inst,
              drain_done => drain_done_inst,   crc_ok => crc_ok_inst,
              data_out => data_out_inst,   crc_out => crc_out_inst );
end inst;

-- Configuration for use with VSS simulator
-- pragma translate_off
configuration DW_crc_s_inst_cfg_inst of DW_crc_s_inst is
  for inst
  end for; -- inst
end DW_crc_s_inst_cfg_inst;
-- pragma translate_on
