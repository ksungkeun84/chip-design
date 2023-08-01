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
-- AUTHOR:    PS		July 30, 1992
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: d74dc05e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Arithmetic Shifter
--           This component performs left and right shifting.  
--           When SH_TC = '0', the shift coefficient SH is interpreted as a
--	     positive unsigned number and only left shifts are performed.
--           When SH_TC = '1', the shift coefficient SH is a signed two's 
--           complement number. A negative coefficient indicates
--           a right shift (division) and a positive coefficient indicates
--           a left shift (multiplication).
--           The input data A can also be interpreted as an unsigned or signed
--           number.  When DATA_TC = '0', A and B are unsigned numbers.  When
--           DATA_TC = '1', A and B are interpreted as signed two's complement numbers.
--           The coding of A only affects B when right shifts are performed 
--           (ie. when SH_TC = '1')  Under these circumstances, B is zero padded on
--           the MSBs when A and B are unsigned, and sign extended on the MSBs
--           when A and B are signed two's complement numbers.
--
-- MODIFIED:
--	10/14/1998	Jay Zhu	STAR 59348
--      03/28/2005      Alex Tenca - took away the SH_xx_xx_ARG function during
--                      actual build of the dware tree 
--                      (included #ifdef _EXTERN_DEV_ENV)
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW01_ash is
   generic(A_width, SH_width : POSITIVE);
   port(A : in std_logic_vector(A_width-1 downto 0);	-- input data
        DATA_TC : in std_logic;				-- 2's compl/unsigned data control
        SH : in std_logic_vector(SH_width-1 downto 0);	-- shift coefficient
        SH_TC : in std_logic;				-- 2's compl/unsigned shift coef. control
        B : out std_logic_vector(A_width-1 downto 0));	-- shifted data
end DW01_ash;
 
