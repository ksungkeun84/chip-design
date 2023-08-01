--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1995 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    KB              May 20, 1995
--
-- VERSION:   VHDL Entity File for DW_iir_dc
--
-- DesignWare_version: 59fad1cc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  DW_iir_dc is a high-speed digital IIR filter with 
--            dynamic coefficients
--
-- MODIFIED:  Zhijun (Jerry) Huang      02/12/2004
--            Changed interface names
--            Added new parameter out_reg and new asynchronous reset rst_n
--            Added parameter default values and legality check expressions
--
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
entity DW_iir_dc is 
	generic(data_in_width	: POSITIVE := 8;
		data_out_width	: POSITIVE := 16;
		frac_data_out_width	: NATURAL := 4;
		feedback_width	: POSITIVE := 12;
		max_coef_width	: POSITIVE := 8;
		frac_coef_width	: NATURAL := 4;
		saturation_mode	: NATURAL  := 0;
                out_reg		: NATURAL  := 1);
	port(	clk		: in  std_logic;
		rst_n		: in  std_logic;
                init_n		: in  std_logic;
		enable		: in  std_logic;
		A1_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		A2_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		B0_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		B1_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		B2_coef		: in  std_logic_vector(max_coef_width-1 downto 0);
		data_in		: in  std_logic_vector(data_in_width-1 downto 0);
		data_out	: out std_logic_vector(data_out_width-1 downto 0);
		saturation	: out std_logic);
end DW_iir_dc;

