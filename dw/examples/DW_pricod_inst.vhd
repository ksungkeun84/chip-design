library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;
-- If using numeric types from std_logic_arith package,
-- comment the preceding line and uncomment the following line:
-- use DWARE.DW_Foundation_comp_arith.all;


entity DW_pricod_inst is

  generic (
    inst_a_width : POSITIVE := 8);
  
  port (
    inst_a    : in  std_logic_vector(inst_a_width-1 downto 0);
    cod_inst  : out std_logic_vector(inst_a_width-1 downto 0);
    zero_inst : out std_logic);
  
end DW_pricod_inst;


architecture inst of DW_pricod_inst is

begin

  -- Instance of DW_pricod
  U1 : DW_pricod
    generic map (a_width => inst_a_width)
    port map (a => inst_a, cod => cod_inst, zero => zero_inst);

end inst;


-- pragma translate_off
configuration DW_pricod_inst_cfg_inst of DW_pricod_inst is
  for inst
  end for;
end DW_pricod_inst_cfg_inst;
-- pragma translate_on
