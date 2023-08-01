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
-- AUTHOR:    Reto Zimmermann    Sept. 12, 2006
--
-- VERSION:   Entity
--
-- DesignWare_version: c9d3907b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Priority Coder
--
-- MODIFIED: 
--
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_pricod is
  
   generic (
     a_width  : POSITIVE := 8);   -- input width

   port (
     a    : in  std_logic_vector(a_width-1 downto 0);  -- input
     cod  : out std_logic_vector(a_width-1 downto 0);    -- coded output
     zero : out std_logic);                            -- all-zero flag

end DW_pricod;

