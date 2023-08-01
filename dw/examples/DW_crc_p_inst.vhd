library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_crc_p_inst is
  generic (inst_data_width : INTEGER := 19;  inst_poly_size  : INTEGER := 5;
           inst_crc_cfg    : INTEGER := 7;   inst_bit_order  : INTEGER := 0;
           inst_poly_coef0 : INTEGER := 5;   inst_poly_coef1 : INTEGER := 0;
           inst_poly_coef2 : INTEGER := 0;   inst_poly_coef3 : INTEGER := 0 
           );
  port (inst_data_in : in std_logic_vector(inst_data_width-1 downto 0);
        inst_crc_in  : in std_logic_vector(inst_poly_size-1 downto 0);
        crc_ok_inst  : out std_logic;
        crc_out_inst : out std_logic_vector(inst_poly_size-1 downto 0)  );
end DW_crc_p_inst;

architecture inst of DW_crc_p_inst is
begin

  -- Instance of DW_crc_p
  U1 : DW_crc_p
    generic map (data_width => inst_data_width,  poly_size => inst_poly_size,
                 crc_cfg => inst_crc_cfg,        bit_order => inst_bit_order,
                 poly_coef0 => inst_poly_coef0, 
                 poly_coef1 => inst_poly_coef1,
                 poly_coef2 => inst_poly_coef2,
                 poly_coef3 => inst_poly_coef3 )
    port map (data_in => inst_data_in,   crc_in => inst_crc_in,
              crc_ok => crc_ok_inst,    crc_out => crc_out_inst );
end inst;

configuration DW_crc_p_inst_cfg_inst of DW_crc_p_inst is
  for inst
  end for;
end DW_crc_p_inst_cfg_inst;

