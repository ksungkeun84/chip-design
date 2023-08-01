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
-- AUTHOR:    Kyung-Nam Han  Oct. 27, 2005
--
-- VERSION:   VHDL Entity for DW_fp_flt2i
--
-- DesignWare_version: 3855ee80
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

--
-- ABSTRACT:  Floating-point Number Format to Integer Number Format Converter
--		
--		This converts a floating-point number to a signed integer number.
--		Conversion to a unsigned integer number is not supported.
--
--		parameters      valid values (defined in the DW manual)
--		==========      ============
--		sig_width       significand size, 	2 to 253 bits
--		exp_width       exponent size, 	3 to 31 bits
--		isize           integer size,	3 to 512 bits
--      ieee_compliance support the IEEE Compliance 
--                      0 - IEEE 754 compatible without denormal support
--                          (NaN becomes Infinity, Denormal becomes Zero)
--                      1 - IEEE 754 compatible with denormal support
--                          (NaN and denormal numbers are supported)
--
--		Input ports	Size & Description
--		===========	==================
--		a		(sig_width + exp_width + 1)-bits
--				Floating-point Number Input
--		rnd		3 bits
--				Rounding Mode Input
--		z		(isize)-bits
--				Converted Integer Output
--		status		8 bits
--				Status Flags Output
-- 		
-- Modified:
--   Sep.09.2009 Kyung-Nam Han (C-2009.03-SP3)
--     Added ieee_compliance parameter
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_flt2i is

  generic(sig_width      : POSITIVE := 23;
          exp_width      : POSITIVE   := 8;
          isize          : integer   := 32;
          ieee_compliance: integer  := 0
         );

  port(  a        : in std_logic_vector(sig_width + exp_width downto 0);
         rnd      : in std_logic_vector(2 downto 0);
         z        : out std_logic_vector(isize - 1 downto 0);
         status   : out std_logic_vector(7 downto 0)
      );

end DW_fp_flt2i;


