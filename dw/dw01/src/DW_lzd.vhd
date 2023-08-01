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
-- AUTHOR:    Doug Lee    Jul. 7, 2005
--
-- VERSION:   Entity
--
-- DesignWare_version: 74fd9332
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Leading Zeros Detector
--
-- MODIFIED: 
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_lzd is
   generic (
     a_width  : POSITIVE := 8);   -- input width

   port (
     a   : in  std_logic_vector(a_width-1 downto 0);           -- input
     enc : out std_logic_vector(bit_width(a_width) downto 0);  -- encoded output
     dec : out std_logic_vector(a_width-1 downto 0)            -- decoded output
        );
end DW_lzd ;
