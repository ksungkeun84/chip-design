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
-- AUTHOR:    Alexandre Tenca   Feb 2008
--
-- VERSION:   VHDL Entity File for DW_thermdec
--
-- DesignWare_version: dc25171e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Binary Thermometer decoder 
--           A binary thermometer decoder of an n-bit input has 2^n outputs.
--           Each output corresponds to one value of the binary input, and 
--           for an input value i, all the outputs corresponding to j<=i area
--           active.
--           eg. n=3 
--           A(2:0) en     B(7:0)
--           000    1   -> 00000001
--           001    1   -> 00000011
--           010    1   -> 00000111
--           011    1   -> 00001111
--           100    1   -> 00011111
--           101    1   -> 00111111
--           110    1   -> 01111111
--           111    1   -> 11111111
--           xxx    0   -> 00000000
-- 
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              width           input size
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               width bits
--                              Input to be decoded
--              en              bit
--                              Enable 
--
--              Output ports    Size & Description
--              ===========     ==================
--              b               2**width bits
--                              Decoded output for value in port a
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_thermdec is
   generic(width : NATURAL := 3);
   port(en : in std_logic;
        a  : in std_logic_vector(width-1 downto 0);  
        b  : out std_logic_vector(2**width-1 downto 0));
end DW_thermdec;
 

