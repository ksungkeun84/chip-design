--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2005 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre Tenca   March 2005
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 0447d47e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Inverse square-root B=(A)^{-1/2}
--           Computes the reciprocal of the square-root of A using a
--           digit recurrence algorithm. 
--           Input A must be in the range 1/4 < A < 1
--           Output B is in the range 1 < B < 2
--           Both input and output are considered unsigned.
--
-- MODIFIED:
--           1/30/2007: modified upper bound of prec_control
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_inv_sqrt is
   generic(a_width : POSITIVE := 8;        -- size of input and output operand
           prec_control : INTEGER := 0);   -- indicates the number of bits that 
                                           -- can be removed from the internal precision
   port(a : in std_logic_vector(a_width-1 downto 0);   -- input data
        b : out std_logic_vector(a_width-1 downto 0); -- output data
        t : out std_logic);
end DW_inv_sqrt;
 
