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
-- AUTHOR:    Alexandre Tenca  February, 11  2005
--
-- VERSION:   Entity
--
-- DesignWare_version: 6500cd3f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Bidirectional Barrel Shifter - Prefers Left direction
--           This component performs left and right rotation.  
--           When SH_TC = '0', the rotation coefficient SH is interpreted as a
--	     positive unsigned number and only left rotation is performed.
--           When SH_TC = '1', the rotation coefficient SH is interpreted as a 
--           signed two's complement number. A negative coefficient indicates
--           a right rotation and a positive coefficient indicates a left rotation.
--           The input data A is always considered as a simple bit vector (unsigned).
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
entity DW_rbsh is
   generic(A_width,SH_width : POSITIVE);
   port(A : in std_logic_vector(A_width-1 downto 0);          -- main input data
        SH : in std_logic_vector(SH_width-1 downto 0);        -- rotation distance
        SH_TC : in std_logic;				        -- 2's compl/unsigned shifting distance
        B : out std_logic_vector(A_width-1 downto 0));
end DW_rbsh;
 
