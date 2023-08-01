--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    KB			February 7, 1994
--
-- VERSION:   VHDL Entity
--
-- DesignWare_version: 05f22e0d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Universal Multiplexer
--           A_width-Bits => MUX_width-Bits
--
---------------------------------------------------------------------------------
--
--      WSFDB revision control info
--                      @(#)DW01_mux_any.vhd	1.2
--
--  MODIFIED :
--		2/18/08  RJK  Added bal_str parameter
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_mux_any is
   generic( A_width, SEL_width, MUX_width : POSITIVE;  -- input & output wordlengths
	    bal_str : INTEGER  := 0);
   port(A : in std_logic_vector(A_width-1 downto 0);  
        SEL : in std_logic_vector(SEL_width-1 downto 0);  
        MUX : out std_logic_vector(MUX_width-1 downto 0));
end DW01_mux_any;
