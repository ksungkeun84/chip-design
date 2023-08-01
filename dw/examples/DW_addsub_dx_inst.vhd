library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp_arith.all;

entity DW_addsub_dx_inst is
  generic ( inst_width    : NATURAL := 24; 
            inst_p1_width : NATURAL := 16 );
  port ( inst_a      : in std_logic_vector(inst_width-1 downto 0);
         inst_b      : in std_logic_vector(inst_width-1 downto 0);
         inst_ci1    : in std_logic; 
         inst_ci2    : in std_logic;
         inst_addsub : in std_logic;
         inst_tc     : in std_logic;
         inst_sat    : in std_logic;
         inst_avg    : in std_logic;
         inst_dplx   : in std_logic;
         sum_inst    : out std_logic_vector(inst_width-1 downto 0);
         co1_inst    : out std_logic;
         co2_inst    : out std_logic  );
end DW_addsub_dx_inst;

architecture inst of DW_addsub_dx_inst is
begin

  -- Instance of DW_addsub_dx
  U1 : DW_addsub_dx
    generic map ( width => inst_width,  p1_width => inst_p1_width )
    port map ( a => inst_a, b => inst_b,
               ci1 => inst_ci1, ci2 => inst_ci2, addsub => inst_addsub, 
               tc => inst_tc, sat => inst_sat, avg => inst_avg,
               dplx => inst_dplx, sum => sum_inst,
               co1 => co1_inst, co2 => co2_inst  );
end inst;

-- pragma translate_off
configuration DW_addsub_dx_inst_cfg_inst of DW_addsub_dx_inst is
  for inst
  end for; -- inst
end DW_addsub_dx_inst_cfg_inst;
-- pragma translate_on
