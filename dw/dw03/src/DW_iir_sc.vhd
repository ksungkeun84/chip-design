--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1996 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    KB              April 22, 1996
--
-- VERSION:   VHDL Entity File for DW_iir_sc
--
-- DesignWare_version: 6a8d4c44
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  DW_iir_sc is a high-speed digital IIR filter with 
--            static coefficients
--
-- MODIFIED:  
--            Doug Lee     06/05/2008
--              Added legal condition to __common_impl_sl_code__ block 
--
--            Zhijun (Jerry) Huang      02/17/2004
--              Changed interface names
--              Added new parameter out_reg and new asynchronous reset rst_n
--              Added parameter default values and legality check expressions
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_iir_sc is 
	generic(data_in_width	: POSITIVE := 4;
		data_out_width	: POSITIVE := 6;
		frac_data_out_width	: NATURAL := 0;
		feedback_width	: POSITIVE := 8;
		max_coef_width	: POSITIVE  := 4;
		frac_coef_width	: NATURAL  := 0;
		saturation_mode	: NATURAL  := 1;
                out_reg		: NATURAL  := 1;
		A1_coef		: INTEGER := -2;
		A2_coef		: INTEGER :=  3;
		B0_coef		: INTEGER :=  5;
		B1_coef		: INTEGER := -6;
		B2_coef		: INTEGER := -2);
	port(	clk		: in  std_logic;
        	rst_n		: in  std_logic;
		init_n		: in  std_logic;
		enable		: in  std_logic;
		data_in		: in  std_logic_vector(data_in_width-1 downto 0);
		data_out	: out std_logic_vector(data_out_width-1 downto 0);
		saturation	: out std_logic);
end DW_iir_sc;

