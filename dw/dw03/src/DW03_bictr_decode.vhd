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
-- AUTHOR:    GN          April 12, 1993 
--
-- VERSION:   Entity
--
-- DesignWare_version: 7cf763e6
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Up/Down Binary Counter w. Output Decode
--           programmable wordlength (width > 0)
--           programmable count_to ( count_to = 1 to 2**width-1)  
--            
-- MODIFIED: 
--          
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW03_bictr_decode is
  generic(width: POSITIVE);
  port(data: in std_logic_vector(width-1 downto 0);
       up_dn, load, cen, clk, reset : in std_logic;
       count_dec: out std_logic_vector(2**width-1 downto 0);
       tercnt: out std_logic); 
end DW03_bictr_decode;
