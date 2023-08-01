--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2008 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Kyung-Nam Han	 Jul. 7, 2008
--
-- VERSION:   Entity
--
-- DesignWare_version: 95f9c25c
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Fixed-Point Sine/Cosine Unit
--
--              DW_sincos calculates the fixed-point sine/cosine 
--              function. 
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              A_width         input,      2 to 34 bits
--              WAVE_width      output,     2 to 35 bits
--              arch            implementation select
--                              0 - area optimized (default)
--                              1 - speed optimized
--              err_range       error range of the result compared to the
--                              true result
--                              1 - 1 ulp error (default)
--                              2 - 2 ulp error
--
--              Input ports     Size & Description
--              ===========     ==================
--              A               A_width bits
--                              Fixed-point Number Input
--              SIN_COS         1 bit
--                              Operator Selector
--                              0 - sine, 1 - cosine
--              WAVE            WAVE_width bits
--                              Fixed-point Number Output
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_sincos is

  generic( 
    A_width    : INTEGER  := 24;
    WAVE_width : INTEGER  := 25;
    arch       : INTEGER  := 0;
    err_range  : INTEGER  := 1
  );

  port(
    A       : in std_logic_vector(A_width-1 downto 0);  
    SIN_COS : in std_logic;		-- Sine -> '0', Cosine -> '1'
    WAVE    : out std_logic_vector(WAVE_width-1 downto 0)
  );


end DW_sincos;
