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
-- AUTHOR:    PS			Jan. 22, 1992
--
-- VERSION:   Entity
--
-- DesignWare_version: 0590b93b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Absolute Value
--           This operator assumes that the input A is coded as a two's complement
--           number.  The sign std_logic A(n-1) determines whether the input is positive
--           or negative.
--           
--           A(n-1)	ABSVAL
--	     -------+----------
--            '0'   |	 A
--            '1'   |	-A
--          
--           The value -A is computed as (A') + '1'
--
--
-- MODIFIED: 
--	10/14/1998	Jay Zhu	STAR 59348
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_absval is
  generic(width : NATURAL);
  port(A : std_logic_vector(width-1 downto 0);
       ABSVAL : out std_logic_vector(width-1 downto 0));
end DW01_absval;
