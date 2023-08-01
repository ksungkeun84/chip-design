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
-- AUTHOR:    PS			Jan. 5, 1992
--
-- VERSION:   Entity
--
-- DesignWare_version: 9f94a114
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Pipeline Register
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW03_pipe_reg is 
   generic (depth : INTEGER;  
            width : INTEGER); 
   port(A : in std_logic_vector (width-1 downto 0);
        clk : in std_logic;
        B : out std_logic_vector(width-1 downto 0));
end DW03_pipe_reg;
