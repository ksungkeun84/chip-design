library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW04_par_gen_inst is
  generic (inst_width    : POSITIVE := 8;
           inst_par_type : INTEGER := 1  );
  port (inst_datain : in std_logic_vector(inst_width-1 downto 0);
        parity_inst : out std_logic  );
end DW04_par_gen_inst;

architecture inst of DW04_par_gen_inst is
begin

  -- Instance of DW04_par_gen
  U1 : DW04_par_gen
    generic map (width => inst_width,   par_type => inst_par_type )
    port map ( datain => inst_datain,   parity => parity_inst );
end inst;

-- pragma translate_off
configuration DW04_par_gen_inst_cfg_inst of DW04_par_gen_inst is
  for inst
  end for; -- inst
end DW04_par_gen_inst_cfg_inst;
-- pragma translate_on

