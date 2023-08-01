--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1992 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Scott MacKay			May, 20, 1993
--
-- VERSION:   entity DW03_shftreg
--
-- DesignWare_version: ef8c32a2
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Shift Register
--           length wordlength
--           shift enable active low
--           parallel load enable active low
-- MODIFIED: 
--          
--         
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
entity DW03_shftreg is
	generic	(length :	positive ) ;
	port
	(	clk:		in std_logic;
		s_in:		in std_logic;
		p_in:		in std_logic_vector (length-1 downto 0) ;
		shift_n:	in std_logic;
		load_n:		in std_logic;
		p_out:		out	std_logic_vector (length-1 downto 0) );
end DW03_shftreg;
