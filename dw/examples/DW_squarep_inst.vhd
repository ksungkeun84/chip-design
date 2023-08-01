library IEEE,DW01,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_foundation_comp.all;

-- Square & Accumulate performed by instances of
-- DW_squarep, DW01_csa & DW01_add

entity DW_squarep_inst is
  generic ( inst_width : NATURAL := 6;
            inst_verif_en : INTEGER := 3 );-- level 3 is the most aggressive
                                           -- verification mode for simulation
  port ( inst_a : in std_logic_vector(inst_width-1 downto 0);
         inst_b : in std_logic_vector(2*inst_width-1 downto 0);
         inst_tc : in std_logic;
         accum_inst : out std_logic_vector(2*inst_width-1 downto 0) );
end DW_squarep_inst;

architecture inst of DW_squarep_inst is
  signal part_prod1, part_prod2 : std_logic_vector(2*inst_width-1 downto 0);
  signal part_sum1, part_sum2 : std_logic_vector(2*inst_width-1 downto 0);
  signal tied_low, no_connect1, no_connect2 : std_logic;
begin
  -- Instance of DW_squarep to perform the partial
  -- multiply of inst_a by inst_a with partial product
  -- results at part_prod1 & part_prod2
  U1 : DW_squarep
    generic map ( width => inst_width,
                  verif_en => inst_verif_en )
    port map ( a => inst_a, tc => inst_tc,
               out0 => part_prod1, out1 => part_prod2 );


  -- Instance of DW01_csa used to add the partial products
  -- from inst_a times inst_a (part_prod1 & part_prod2) to
  -- the input inst_b in carry-save form yielding the two
  -- vectors, part_sum1 & part_sum2.
  U2 : DW01_csa
    generic map (width => 2*inst_width)
    port map ( a => part_prod1, b => part_prod2, c => inst_b,
               ci => tied_low, sum => part_sum1,
               carry => part_sum2, co => no_connect1 );

  -- Finally, an instqance of DW01_add is used to add the carry-save
  -- partial results together forming the final binary output
  U3 : DW01_add
    generic map (width => 2*inst_width)
    port map ( A => part_sum1, B => part_sum2, CI => tied_low,
               SUM => accum_inst, CO => no_connect2 );
  tied_low <= '0';
end inst;

-- pragma translate_off
configuration DW_squarep_inst_cfg_inst of DW_squarep_inst is
  for inst
  end for; -- inst
end DW_squarep_inst_cfg_inst;
-- pragma translate_on
