library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

entity DW_fir_inst is
  generic (inst_data_in_width : POSITIVE := 8;
           inst_coef_width : POSITIVE := 8;
           inst_data_out_width : POSITIVE := 18;
           inst_order : POSITIVE := 6 );
  port (inst_clk     : in std_logic;
        inst_rst_n   : in std_logic;
        inst_coef_shift_en : in std_logic;
        inst_tc      : in std_logic;
        inst_data_in : in std_logic_vector(inst_data_in_width-1 downto 0);
        inst_coef_in : in std_logic_vector(inst_coef_width-1 downto 0);
        inst_init_acc_val : in 
           std_logic_vector(inst_data_out_width-1 downto 0);
        data_out_inst : out std_logic_vector(inst_data_out_width-1 downto 0);
        coef_out_inst : out std_logic_vector(inst_coef_width-1 downto 0) );
end DW_fir_inst;

architecture inst of DW_fir_inst is
begin
  -- Instance of DW_fir
  U1 : DW_fir
    generic map (data_in_width => inst_data_in_width, 
                 coef_width => inst_coef_width, 
                 data_out_width => inst_data_out_width, order => inst_order )
    port map (clk => inst_clk,   rst_n => inst_rst_n, 
              coef_shift_en => inst_coef_shift_en,   tc => inst_tc, 
              data_in => inst_data_in,   coef_in => inst_coef_in,
              init_acc_val => inst_init_acc_val,   data_out => data_out_inst,
              coef_out => coef_out_inst );
end inst;

