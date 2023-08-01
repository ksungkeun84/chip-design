library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_fp_ln_inst is
   generic (
       inst_sig_width : POSITIVE := 10;
       inst_exp_width : POSITIVE := 5;
       inst_ieee_compliance : INTEGER := 0;
       inst_extra_prec : INTEGER := 0;
       inst_arch : INTEGER := 0
            );
   port (
       inst_a : in std_logic_vector(inst_sig_width+inst_exp_width downto 0);
       z_inst : out std_logic_vector(inst_sig_width+inst_exp_width downto 0);
       status_inst : out std_logic_vector(7 downto 0)
       );
   end DW_fp_ln_inst;

architecture inst of DW_fp_ln_inst is

begin

    -- Instance of DW_fp_ln
    U1 : DW_fp_ln
        generic map (
                sig_width => inst_sig_width,
                exp_width => inst_exp_width,
                ieee_compliance => inst_ieee_compliance,
                extra_prec => inst_extra_prec,
                arch => inst_arch
                )
        port map (
                a => inst_a,
                z => z_inst,
                status => status_inst
                );

end inst;

-- pragma translate_off
configuration DW_fp_ln_cfg_inst of DW_fp_ln_inst is
 for inst
 end for; -- inst
end DW_fp_ln_cfg_inst;
-- pragma translate_on
