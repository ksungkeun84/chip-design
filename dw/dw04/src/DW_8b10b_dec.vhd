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
-- DesignWare_version: a4f01b7b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: 8b10b decoder
--	Parameters:
--		bytes : Number of bytes to decode.
--		k28_5_only : Special character subset control
--			parameter (0 for all special characters
--			decoded, 1 for only K28.5 decoded [when
--			k_char=HIGH implies K28.5, all other special
--			characters indicate a code error])
--		en_mode : 0 => enable not connected (backward campat.)
--			  1 => enable=0 stalls decoder
--              init_mode : during initialization the method in which
--                          input init_rd_val is applied to data_in.
--                            0 => init_rd_val input is registered
--                                 before being applied to data in
--                            1 => init_rd_val input is not registered
--		rst_mode : 0 => use asynchronous reset
--			   1 => use synchronous reset
--              op_iso_mode : Operand Isolation mode
--                            '0': Follow intent defined by Power Compiler user setting
--                            '1': no isolation
--                            '2': 'and' gate isolation
--                            '3': 'or' gate isolation
--                            '4': preferred isolation style: 'and' gate
--
--	Inputs:
--		clk : 	Clock
--		rst_n :	Asynchronous reset, active low
--		init_rd_n : Synchronous initialization, active low
--		init_rd_val : Value of initial running disparity
--		data_in : Input data for decoding, normally should be
--			8b10b encoded data
--	Outputs:
--		error : Error output indicator, active high
--		rd :	Current running disparity (after decoding data
--			presented at data_in)
--		k_char : Special character indicators (one indicator
--			per decoded byte)
--		data_out : decoded output data
--		rd_err : Running disparity Error
--		code_err : Coding error
--	Input:
--		enable : Enables register clocking
--
--  Modified:
--    2/19/08  DLL  Added 'op_iso_mode' parameter
--
--    10/6/08  RJK
--             Added rst_mode parameter to select reset type
--             (STAR 9000270234)
--
------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_8b10b_dec is
	generic(
		bytes :		integer  := 2;
		k28_5_only :	integer   := 0;
		en_mode :	integer   := 0;
		init_mode :	integer   := 0;
		rst_mode :	integer   := 0;
                op_iso_mode :   integer   := 0
		);
	port(
		clk : 		in std_logic;
		rst_n : 	in std_logic;
		init_rd_n :	in std_logic;
		init_rd_val :	in std_logic;
		data_in :	in std_logic_vector(bytes*10-1 downto 0);
		error :		out std_logic;
		rd :		out std_logic;
		k_char :	out std_logic_vector(bytes-1 downto 0);
		data_out :	out std_logic_vector(bytes*8-1 downto 0);
		rd_err :	out std_logic;
		code_err :	out std_logic;
		enable :	in std_logic;
		rd_err_bus :	out std_logic_vector(bytes-1 downto 0);
		code_err_bus :	out std_logic_vector(bytes-1 downto 0)
		);
end DW_8b10b_dec;
