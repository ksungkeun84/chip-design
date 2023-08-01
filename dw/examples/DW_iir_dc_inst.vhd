library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_iir_dc_inst is
  generic (inst_data_in_width       : POSITIVE := 8;
           inst_data_out_width      : POSITIVE := 16;
           inst_frac_data_out_width : NATURAL := 4;
           inst_feedback_width      : POSITIVE := 12;
           inst_max_coef_width      : POSITIVE := 8;
           inst_frac_coef_width     : NATURAL := 4;
           inst_saturation_mode     : NATURAL := 0;
           inst_out_reg             : NATURAL := 1  );
  port (inst_clk : in std_logic;
        inst_rst_n : in std_logic;
        inst_init_n : in std_logic;
        inst_enable : in std_logic;
        inst_A1_coef : in std_logic_vector(inst_max_coef_width-1 downto 0);
        inst_A2_coef : in std_logic_vector(inst_max_coef_width-1 downto 0);
        inst_B0_coef : in std_logic_vector(inst_max_coef_width-1 downto 0);
        inst_B1_coef : in std_logic_vector(inst_max_coef_width-1 downto 0);
        inst_B2_coef : in std_logic_vector(inst_max_coef_width-1 downto 0);
        inst_data_in : in std_logic_vector(inst_data_in_width-1 downto 0);
        data_out_inst : out std_logic_vector(inst_data_out_width-1 downto 0);
        saturation_inst : out std_logic  );
end DW_iir_dc_inst;

architecture inst of DW_iir_dc_inst is
begin
  -- Instance of DW_iir_dc
  U1 : DW_iir_dc
    generic map ( data_in_width => inst_data_in_width, 
                  data_out_width => inst_data_out_width, 
                  frac_data_out_width => inst_frac_data_out_width,
                  feedback_width => inst_feedback_width,
                  max_coef_width => inst_max_coef_width, 
                  frac_coef_width => inst_frac_coef_width, 
                  saturation_mode => inst_saturation_mode, 
                  out_reg => inst_out_reg )
    port map ( clk => inst_clk,   rst_n => inst_rst_n, 
               init_n => inst_init_n,   enable => inst_enable, 
               A1_coef => inst_A1_coef,   A2_coef => inst_A2_coef, 
               B0_coef => inst_B0_coef,   B1_coef => inst_B1_coef, 
               B2_coef => inst_B2_coef,   data_in => inst_data_in, 
               data_out => data_out_inst,   saturation => saturation_inst );
end inst;
