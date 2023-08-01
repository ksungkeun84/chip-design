
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2010 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    RJK          July 23, 2010
--
-- VERSION:   Simulation architecture 'sim'
--
-- DesignWare_version: a45560da
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
--
-- ABSTRACT: Low Power Up Counter with Dynamic Terminal Count
--
--
--      Parameters     Valid Values   Description
--      ==========     ============   ===========
--      width           2 to 1024     default: 8
--                                    Width of counter
--
--      rst_mode         0 to 1       default: 0
--                                    Defines whether reset is async or sync
--                                      0 => use asynch reset FFs
--                                      1 => use synch reset FFs
--
--      reg_trmcnt       0 to 1       default: 0
--                                    Defines whether term_count_n is registered
--                                      0 => term_count_n is combination
--                                      1 => term_count_n is registered
--
--
--      Inputs         Size       Description
--      ======         ====       ===========
--      clk            1 bit      Positive edge sensitive Clock Input
--      rst_n          1 bit      Reset Inpur (active low)
--      enable         1 bit      Counter Enable Input (active high)
--      ld_n           1 bit      Reset (active low)
--      ld_count    width bits    Value to Load into Counter
--      term_val    width bits    Input to Specify the Terminal Count Value
--
--
--      Outputs        Size       Description
--      =======        ====       ===========
--      count       width bits    Counter Output
--      term_count_n   1 bit      Terminal Count Output Flag (active low)
--
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

architecture sim of DW_lp_cntr_up_df is
  signal count_int      : UNSIGNED(width-1 downto 0);
  signal count_plus_one : UNSIGNED(width-1 downto 0);
  signal count_next     : UNSIGNED(width-1 downto 0);
  constant one          : UNSIGNED(width-1 downto 0) := CONV_UNSIGNED(1, width) ;
  signal term_count_n_int  : std_logic;
  signal term_count_n_next : std_logic;
begin
-- pragma translate_off

  count_plus_one <= count_int + one;

  count_next <= UNSIGNED(ld_count) WHEN (ld_n = '0') ELSE (others => 'X') WHEN (ld_n /= '1') ELSE
			count_plus_one WHEN (enable = '1') ELSE count_int WHEN (enable = '0')
			ELSE (others => 'X');

  G1 : if (rst_mode = 0) generate
    PROC_registers: process(clk, rst_n) begin
      if (rst_n = '0') then
	count_int <= (others => '0');
	term_count_n_int <= '1';
      else
        if rising_edge(clk) then
	  count_int <= count_next;
	  term_count_n_int <= term_count_n_next;
	end if;
      end if;
    end process;
  end generate G1;

  G2 : if (rst_mode = 1) generate
    PROC_registers: process(clk) begin
      if rising_edge(clk) then
	if (rst_n = '0') then
	  count_int <= (others => '0');
	  term_count_n_int <= '1';
	else
	  count_int <= count_next;
	  term_count_n_int <= term_count_n_next;
	end if;
      end if;
    end process;
  end generate G2;

  count <= std_logic_vector(count_int);

  G3 : if (reg_trmcnt = 0) generate
    term_count_n <= 'X' WHEN (Is_X(term_val) or Is_X(std_logic_vector(count_int))) ELSE
			  '0' WHEN (term_val = std_logic_vector(count_int)) ELSE '1';

    term_count_n_next <= '1';
  end generate G3;

  G4 : if (reg_trmcnt = 1) generate
    term_count_n_next <= term_count_n_int WHEN (ld_n AND NOT enable) = '1'
			  ELSE 'X' WHEN (Is_X(term_val) or
						Is_X(std_logic_vector(count_next))) ELSE
			  '0' WHEN (term_val = std_logic_vector(count_next)) ELSE '1';

    term_count_n <= term_count_n_int;
  end generate G4;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_lp_cntr_up_df_cfg_sim of DW_lp_cntr_up_df is
 for sim
 end for; -- sim
end DW_lp_cntr_up_df_cfg_sim;
-- pragma translate_on
