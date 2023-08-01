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
-- AUTHOR:    Rick Kelly      July 23, 2010
--
-- VERSION:   Entity
--
-- DesignWare_version: 617e66d0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
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
--      rst_state       integer       default: 0
--                                    Defines reset state of the counter
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
--      next_count  width bits    Counter Next State Output
--
--
-- MODIFIED: 
--
--
---------------------------------------------------------------------------------
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_lp_cntr_up_df is
	
	generic (
		    width          : POSITIVE  := 8;
		    rst_mode       : NATURAL  := 0;
		    reg_trmcnt     : NATURAL  := 0
		);
	
	port    (
                    clk             : in std_logic;
                    rst_n           : in std_logic;
                    enable          : in std_logic;
                    ld_n            : in std_logic;
                    ld_count        : in std_logic_vector(width-1 downto 0);
                    term_val        : in std_logic_vector(width-1 downto 0);
                    count           : out std_logic_vector(width-1 downto 0);
                    term_count_n    : out std_logic
		);
end DW_lp_cntr_up_df;
