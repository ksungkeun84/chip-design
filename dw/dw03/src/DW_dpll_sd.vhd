--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bob Tong  		01/26/2000
--
-- VERSION:   Entity
--
-- DesignWare_version: 5343537b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Digital phase-locked loop 
--           
--
--
--		Parameters:	Valid Values
--		==========	============
--		width		[ 1 to 16 ]
--		divisor 	[ 4 to 256 ]
--		gain		[ 1 to 2 ]
--		filter		[ 0 to 8 ]
--		windows       	[ 1 to (divisor+1)/2 ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk     	1 bit	Reference Clock.
--		rst_n		1 bit	Active Low Reset.
--		stall		1 bit   Active High stall control input **
--		squelch		1 bit   Active High lock disable input
--		window		L bit	Sampling window control input bus	
--              data_in         width 	Data input stream bus 
--
--		Output Ports	Size	Description
--		============	====	===========
--		clk_out		1 bit   Output clock signal for 
--					synchronization.	
--		bit_ready	1 bit	data_out ready signal.	
--		data_out	width	Recovered data stream
--					synchronized to the output
--					time domain.	
--		
--                Note: the value of L is parameter windows 
--		
--
--
-- MODIFIED:
--
---------------------------------------------------------------------------
--
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_dpll_sd is
	
	generic (
	            width : INTEGER  := 1;
		    divisor : INTEGER  := 4;
		    gain : INTEGER  := 1;
		    filter : INTEGER  := 2;
		    windows : INTEGER  := 1
		);
	
	port    (
		    clk : in std_logic;
		    rst_n : in std_logic;
		    stall : in std_logic;
		    squelch : in std_logic;
                    window : in std_logic_vector(bit_width(windows)-1 downto 0);
		    data_in : in std_logic_vector(width-1 downto 0);

		    clk_out : out std_logic;
		    bit_ready : out std_logic;
		    data_out : out std_logic_vector(width-1 downto 0)
		);
end DW_dpll_sd;
