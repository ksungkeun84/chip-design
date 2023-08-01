library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_log2_inst is
      generic (
            inst_op_width : INTEGER := 8;
            inst_arch : INTEGER := 2;
            inst_err_range : INTEGER := 1
            );
      port (
            inst_a : in std_logic_vector(inst_op_width-1 downto 0);
            z_inst : out std_logic_vector(inst_op_width-1 downto 0)
            );
    end DW_log2_inst;


architecture inst of DW_log2_inst is

begin

    -- Instance of DW_log2
    U1 : DW_log2
        generic map (
                op_width => inst_op_width,
                arch => inst_arch,
                err_range => inst_err_range
                )
        port map (
                a => inst_a,
                z => z_inst
                );


end inst;

-- pragma translate_off
configuration DW_log2_inst_cfg_inst of DW_log2_inst is
for inst
end for; -- inst
end DW_log2_inst_cfg_inst;
-- pragma translate_on
