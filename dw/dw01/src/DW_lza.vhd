----------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2004 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean Aug 15 2007
--
-- VERSION:   Entity
--
-- DesignWare_version: a770ea4e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
-- ABSTRACT: Leadgin zero predictor/anticipator
--           conditions: a>=b in unsigned binary numbers, outputs estimated
--           shift count of leading zeros.
--           - 
--           - 
-- 
-- MODIFIED:
--         090907 JBD Original entity.
--
-------------------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
--
entity DW_lza is
  generic (width : natural := 7);
  port ( 
        a     : in  std_logic_vector(width-1 downto 0); -- input
        b     : in  std_logic_vector(width-1 downto 0); -- input
        count : out std_logic_vector(bit_width(width)-1 downto 0));-- decoded output
end DW_lza ;
