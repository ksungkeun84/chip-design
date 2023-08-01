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
-- AUTHOR:    Alexandre Tenca   June 2007
--
-- VERSION:   VHDL Entity File version 1.0
--
-- DesignWare_version: 5459b091
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Fixed-point base-2 logarithm (DW_log2)
--           Computes the base-2 logarithm of a fixed point value in the 
--           range [1,2) delivering a result in the range [0,1).
--           The number of fractional bits to be used is controlled by
--           a parameter. 
--
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              op_width        operand size,  >= 2
--                              includes the integer bit
--              arch            implementation select
--                              0 - area optimized 
--                              1 - speed optimized
--                              2 - 2007.12 implementation (default)
--              err_range       error range of the result compared to the
--                              true result. Default is used when arch=2.
--                              1 - 1 ulp error (default)
--                              2 - 2 ulp error
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               main input with op_width fractional bits
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               op_width fractional bits. log2(a)
--
-- MODIFIED:
--           August 2008 - Included new parameter to control alternative arch
--                         and err_range
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_log2 is
   generic(op_width   : INTEGER := 8;
           arch       : INTEGER  := 2;
           err_range  : INTEGER  := 1);
   port(a : in std_logic_vector(op_width-1 downto 0);   
        z : out std_logic_vector(op_width-1 downto 0));
end DW_log2;
 

