--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2007 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly      May 2, 2007
--
-- VERSION:   Verilog Simulation Model
--
-- DesignWare_version: c9bc44c1
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Pipeline register with parameter control for width, pipe stages
--		as well as non-retimable input or output register
--
--		Register are individually enabled by separate bits of the
--		enable input bus.
--
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ > 0 ]
--              in_reg          [ 0 = no fixed input register
--				  1 = fixed (not retimable) input register ]
--              stages          [ 1 to 1024 ]
--              out_reg         [ 0 = no fixed output register
--				  1 = fixed (not retimable) output register ]
--              rst_mode        [ 0 = asynchronous reset,
--                                1 = synchronous reset ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk		1 bit	Input Clock
--		rst_n		1 bit	Active Low Reset
--		enable	       EW bits	Active High Enable Bus
--		data_in		width	Data input port
--
--		Output Ports	Size	Description
--		============	====	===========
--		data_out	width	Data output port
--
--	where :  EW = max(1, in_reg + stages + out_reg - 1)
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;


entity DW_pl_reg is
	generic (
		width : NATURAL := 8;
		in_reg : INTEGER  := 0;
		stages : INTEGER  := 4;
		out_reg : INTEGER  := 0;
		rst_mode : INTEGER  := 0
		);
	port (
		clk : in std_logic;
		rst_n : in std_logic;
		enable : in std_logic_vector(maximum(0, in_reg+stages+out_reg-2) downto 0);
		data_in : in std_logic_vector(width-1 downto 0);

		data_out : out std_logic_vector(width-1 downto 0)
	     );
end DW_pl_reg;
