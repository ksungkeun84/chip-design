--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly and Jay Zhu  Aug 20, 1999
--
-- VERSION:   Entity
--
-- DesignWare_version: 94b76ebc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: 8b10b encoder
--	Parameters:
--		bytes : Number of bytes to encode.
--		k28_5_only : Special character subset control
--			     0: all 12 special characters available (as determined by data bus value)
--                           1: K28.5 available only (does NOT depend on value of data bus)
--              en_mode: Enable mode
--                       '0': disconnects 'enable' input...always process inputs
--                       '1': use 'enable' input to when process inputs
--              init_mode: Control of init_rd_val
--                         0: init_rd_val input is registered before being applied to data in
--                         1: init_rd_val input is not registered before being applied to data in
--              rst_mode:  Control reset type
--                         0: using aynchronous reset FFs
--                         1: using ynchronous reset FFs
--              op_iso_mode : Operand Isolation mode
--                            '0': Follow intent defined by Power Compiler user setting
--                            '1': no operand isolation
--                            '2': 'and' gate isolation
--                            '3': 'or' gate isolation
--                            '4': preferred isolation style: 'or' gate
--                            
--	Inputs:
--		clk : 	Clock
--		rst_n :	Asynchronous reset, active low
--		init_rd_n : Synchronous initialization, active low
--		init_rd_val : Value of initial running disparity
--		k_char : Special character controls (one indicator
--			per byte to be encoded)
--		data_in : Input data for encoding
--	Outputs:
--		rd :	Current running disparity (before encoding data
--			presented at data_in)
--		data_out : encoded output data
--
--  Modified:
--    2/15/08  DLL  Added 'op_iso_mode' parameter
--
--    10/6/08  RJK
--             Added rst_mode parameter to select reset type
--             (STAR 9000270234)
--
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_8b10b_enc is
	generic(
		bytes :		integer  := 2;
		k28_5_only :	integer   := 0;
		en_mode :	integer   := 0;
		init_mode :	integer   := 0;
		rst_mode :	integer   := 0;
		op_iso_mode :	integer   := 0
		);
	port(
		clk : 		in std_logic;
		rst_n : 	in std_logic;
		init_rd_n :	in std_logic;
		init_rd_val :	in std_logic;
		k_char :	in std_logic_vector(bytes-1 downto 0);
		data_in :	in std_logic_vector(bytes*8-1 downto 0);
		rd :		out std_logic;
		data_out :	out std_logic_vector(bytes*10-1 downto 0);
		enable :	in std_logic
		);
end DW_8b10b_enc;
