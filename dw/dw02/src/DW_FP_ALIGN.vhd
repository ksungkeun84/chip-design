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
-- AUTHOR:    Alexandre Tenca   May 2007
--
-- VERSION:   VHDL Entity File for DW_FP_ALIGN
--
-- DesignWare_version: 4c4941f5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Perform a variable logical right shift on the main input
--           keeping the sticky bit information about the bits spilling
--           out of range. The shifting distance is controlled by an
--           input. The sticky bit output is a single bit that has a value
--           1 when any of the spill out bits is a 1. 
--           This functionality is useful to floating-point operations 
--           and it is called "alignment" operation.
-- 
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              a_width         input size
--              sh_width        shifting distance  size
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               a_width bits
--                              Main input to be shifted
--              sh              sh_width bits
--                              Shifting distance input
--
--              Output ports    Size & Description
--              ===========     ==================
--              b               a_width bits
--                              Shifted output (aligned output)
--              stk             1 bit
--                              Sticky bit output
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_FP_ALIGN is
   generic(a_width : POSITIVE := 23;
	   sh_width : POSITIVE := 8);
   port(a  : in std_logic_vector(a_width-1 downto 0);  
        sh : in std_logic_vector(sh_width-1 downto 0); 
        b : out std_logic_vector(a_width-1 downto 0);
        stk : out std_logic);
end DW_FP_ALIGN;
 

