--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2008 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre Tenca   June 2008
--
-- VERSION:   VHDL Entity File version 1.0
--
-- DesignWare_version: a8740300
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Fixed-point natural logarithm (DW_ln)
--           Computes the natural logarithm of a fixed point value in the 
--           range [1,2).
--           The number of fractional bits to be used is controlled by
--           a parameter. 
--
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              op_width        operand size,  >= 2
--                              includes the integer bit
--              arch            implementation select
--                              0 - area optimized (default)
--                              1 - speed optimized
--              err_range       error range of the result compared to the
--                              true result
--                              1 - 1 ulp error (default)
--                              2 - 2 ulp error
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               main input with op_width fractional bits
--
--              Output ports    Size & Description
--              ===========     ==================
--              z               op_width fractional bits. ln(a)
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_ln is
   generic(op_width   : INTEGER := 8;
           arch       : INTEGER  := 0;
           err_range  : INTEGER  := 1);
   port(a : in std_logic_vector(op_width-1 downto 0);   
        z : out std_logic_vector(op_width-1 downto 0));
end DW_ln;
 

