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
-- AUTHOR:    Kyung-Nam Han  Jan. 18, 2006
--
-- VERSION:   VHDL Entity for DW_fp_i2flt
--
-- DesignWare_version: 012af39b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

--
-- ABSTRACT:  Integer Number Format to Floating-Point Number Format Converter
--
--        This converts an integer number to a floating-point number.
--
--        parameters     valid values (defined in the DW manual)
--        ==========     ==================
--        sig_width      significand size,     2 to 253 bits
--        exp_width      exponent size,        3 to 31 bits
--        isize          integer size,         3 to 512 bits
--        isign          signed/unsigned number flag
--                       0 - unsigned, 1 - signed (2's complement)
--
--        Input ports    Size & Description
--        ===========    ==================
--        a              (isize)-bits
--                       Integer Input
--        rnd            3 bits
--                       Rounding Mode Input
--        z              (sig_width + exp_width + 1)-bits
--                       Floating-point Number Output
--        status         8 bits
--                       Status Flags Output
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_i2flt is

  generic(
    sig_width   : POSITIVE  := 23;
    exp_width   : POSITIVE   := 8;
    isize       : POSITIVE   := 32;
    isign       : integer  := 1
  );

  port(
    a        : in std_logic_vector(isize - 1 downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0)
  );

end DW_fp_i2flt;

