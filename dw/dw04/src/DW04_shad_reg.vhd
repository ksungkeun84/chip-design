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
-- DesignWare_version: 2bfc3adc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Shadow and Multibit Register
--           parameterizable bus size (width > 0) and register stages
--               (bld_shad_reg = 0 -> don't build, = 1 build shad reg)
--	     sys_clk	- positive edge-triggered system clock
--	     shad_clk	- positive edge-triggered clock for shadow reg
--	     SI  	- Serial Scan input port
--	     SE  	- Serial Scan enable port (active high)
--           reset	- asynchronous reset (active low)
--           datain	- input data to system register.
--	     sys_out	- System output bus
--	     shad_out	- Shadowed output bus for diagnostics/test
--	     SO  	- Serial Scan output port
--
-- MODIFIED: 
--          
--		JSR - January 13th, 
--                    Serial ports updated
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity DW04_shad_reg is
  generic(width: POSITIVE;
  	bld_shad_reg: NATURAL );
  port(datain: in std_logic_vector(width-1 downto 0);
       sys_clk, shad_clk, reset : in std_logic;
       SI, SE   : in std_logic;
       sys_out  : out std_logic_vector(width-1 downto 0);
       shad_out : out std_logic_vector(width-1 downto 0);
       SO       : out std_logic);
end DW04_shad_reg;
