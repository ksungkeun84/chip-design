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
-- AUTHOR:    Alex Tenca	February 10, 2005
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 051347c5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Arithmetic Bidirectional Shifter with preferred right direction (DW_rash)
--           This component performs left and right shifting.  
--           When SH_TC = '0', the shift coefficient SH is interpreted as a
--	     positive unsigned number and only right shifts are performed.
--           When SH_TC = '1', the shift coefficient SH is a signed two's 
--           complement number. A negative coefficient indicates
--           a left shift (multiplication) and a positive coefficient indicates
--           a right shift (division).
--           The input data A can also be interpreted as an unsigned or signed
--           number.  When DATA_TC = '0', a logical shift operation is performed on A.  
--           When DATA_TC = '1', a arithmetic shift operation is performed on A.
--           The logical or arithmetic shift is performed on A independent of its 
--           data type (signed or unsigned).
--
-- MODIFIED:
--	
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW_rash is
   generic(A_width : POSITIVE := 8;
           SH_width : POSITIVE := 3);
   port(A : in std_logic_vector(A_width-1 downto 0);		-- input data
        DATA_TC : in std_logic;				-- arithmetic shift control
        SH : in std_logic_vector(SH_width-1 downto 0);	-- shifting distance
        SH_TC : in std_logic;				        -- 2's compl/unsigned shifting distance
        B : out std_logic_vector(A_width-1 downto 0));	-- shifted data
end DW_rash;
 

