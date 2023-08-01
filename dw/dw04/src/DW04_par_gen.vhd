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
-- AUTHOR:    JSR			Feb. 24th, 1993
--
-- VERSION:   Entity
--
-- DesignWare_version: 4a31bf61
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Parity Generator and Checker
--           parameteric bus size ("width" > 0)
--           parameteric "par_type": "0" -> EVEN, "!" -> ODD  
--           datain	- input data to system register.
--           parity	- output parity bit(s).
--
-- MODIFIED: 
--          
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW04_par_gen is
  generic(width: POSITIVE;
          par_type : INTEGER );
  port(datain: in std_logic_vector(width-1 downto 0);
       parity: out std_logic);
end DW04_par_gen;
