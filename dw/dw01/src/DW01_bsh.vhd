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
-- AUTHOR:    PS		Jan. 6, 1992
--
-- VERSION:   Entity
--
-- DesignWare_version: d5240d07
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Barrel Shifter
--
-- MODIFIED:
--	07/09/98	Jay Zhu	STAR56286 fixing.
--	10/14/1998	Jay Zhu	STAR 59348
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_bsh is
   generic(A_width,SH_width : POSITIVE);
   port(A : in std_logic_vector(A_width-1 downto 0);
        SH : in std_logic_vector(SH_width-1 downto 0);
        B : out std_logic_vector(A_width-1 downto 0));
end DW01_bsh;
 
