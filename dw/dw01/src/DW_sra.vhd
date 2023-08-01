--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alex Tenca March 2006
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 6b8044fc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- ABSTRACT: Arithmetic Right Shifter - VHDL style
--           This component performs left and right shifting.
--           When SH_TC = '0', the shift coefficient SH is interpreted as a
--           positive unsigned number and only right shifts are performed.
--           When SH_TC = '1', the shift coefficient SH is a signed two's
--           complement number. A negative coefficient indicates
--           a left shift (division) and a positive coefficient indicates
--           a right shift (multiplication).
--           The input data A is always considered a signed value.
--           The MSB on A is extended when shifted to the right, and the 
--           LSB on A is extended when shifting to the left.
--
-- MODIFIED: 
--
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_sra is
   generic(A_width : POSITIVE := 8;
           SH_width : POSITIVE := 3);
   port(A : in std_logic_vector(A_width-1 downto 0);	-- input data
        SH : in std_logic_vector(SH_width-1 downto 0);-- shift coefficient
        SH_TC : in std_logic;				-- 2's compl/unsigned shift coef. control
        B : out std_logic_vector(A_width-1 downto 0));-- shifted data
end DW_sra;
 
 
