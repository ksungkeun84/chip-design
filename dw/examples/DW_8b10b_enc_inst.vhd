library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_8b10b_enc_inst is
  generic (inst_bytes       : integer := 2;
           inst_k28_5_only  : integer := 0;
           inst_en_mode     : integer := 1;
           inst_init_mode   : integer := 1;
           inst_rst_mode    : integer := 0;
           inst_op_iso_mode : integer := 0 );
  port (inst_clk         : in std_logic;
        inst_rst_n       : in std_logic;
        inst_init_rd_n   : in std_logic;
        inst_init_rd_val : in std_logic;
        inst_k_char      : in std_logic_vector(inst_bytes-1 downto 0);
        inst_data_in     : in std_logic_vector(inst_bytes*8-1 downto 0);
        rd_inst          : out std_logic;
        data_out_inst    : out std_logic_vector(inst_bytes*10-1 downto 0);
        inst_enable      : in std_logic );

end DW_8b10b_enc_inst;

architecture inst of DW_8b10b_enc_inst is
begin
  -- Instance of DW_8b10b_enc
  U1 : DW_8b10b_enc
    generic map (bytes => inst_bytes,   k28_5_only => inst_k28_5_only,
                 en_mode => inst_en_mode, init_mode => inst_init_mode, 
                 rst_mode => inst_rst_mode, op_iso_mode => inst_op_iso_mode )
    port map (clk => inst_clk,   rst_n => inst_rst_n, 
              init_rd_n => inst_init_rd_n,   init_rd_val => inst_init_rd_val,
               k_char => inst_k_char,   data_in => inst_data_in, 
               rd => rd_inst,   data_out => data_out_inst, 
               enable => inst_enable );
end inst;

-- Configuration for use with VHDL simulator
-- pragma translate_off
configuration DW_8b10b_enc_inst_cfg_inst of DW_8b10b_enc_inst is
  for inst
  end for; -- inst
end DW_8b10b_enc_inst_cfg_inst;
-- pragma translate_on
