
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
-- AUTHOR:    Kyung-Nam Han, Sep. 25, 2006
--
-- VERSION:   VHDL Entity for DW_fp_div_seq
--
-- DesignWare_version: 701589e3
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- ABSTRACT: Floating-Point Sequencial Divider
--
--              DW_fp_div_seq calculates the floating-point division
--              while supporting six rounding modes, including four IEEE
--              standard rounding modes.
--
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              sig_width       significand f,  2 to 253 bits
--              exp_width       exponent e,     3 to 31 bits
--              ieee_compliance support the IEEE Compliance 
--                              0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                              1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--              num_cyc         Number of cycles required for the FP sequential
--                              division operation including input and output 
--                              register. Actual number of clock cycle is 
--                              num_cyc - (1 - input_mode) - (1 - output_mode)
--                               - early_start
--              rst_mode        Synchronous / Asynchronous reset 
--                              0 - Asynchronous reset
--                              1 - Synchronous reset
--              input_mode      Input register setup
--                              0 - No input register
--                              1 - Input registers are implemented
--              output_mode     Output register setup
--                              0 - No output register
--                              1 - Output registers are implemented
--              early_start     Computation start (only when input_mode = 1)
--                              0 - start computation in the 2nd cycle
--                              1 - start computation in the 1st cycle (forwarding)
--                              early_start should be 0 when input_mode = 0
--              internal_reg    Insert a register between an integer sequential divider
--                              and a normalization unit
--                              0 - No internal register
--                              1 - Internal register is implemented
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              b               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Input
--              rnd             3 bits
--                              Rounding Mode Input
--              clk             Clock
--              rst_n           Reset. (active low)
--              start           Start operation
--                              A new operation is started by setting start=1
--                              for 1 clock cycle
--              z               (sig_width + exp_width + 1)-bits
--                              Floating-point Number Output
--              status          8 bits
--                              Status Flags Output
--              complete        Operation completed
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fp_div_seq is

  generic(
    sig_width   : POSITIVE  := 23;
    exp_width   : POSITIVE   := 8;
    ieee_compliance: INTEGER     := 0;
    num_cyc     : POSITIVE := 4;
    rst_mode    : INTEGER  := 0;
    input_mode  : INTEGER  := 1;
    output_mode : INTEGER  := 1;
    early_start : INTEGER  := 0;
    internal_reg: INTEGER  := 1
  );

  port(
    a        : in std_logic_vector(sig_width + exp_width downto 0);
    b        : in std_logic_vector(sig_width + exp_width downto 0);
    rnd      : in std_logic_vector(2 downto 0);
    clk      : in std_logic;
    rst_n    : in std_logic;
    start    : in std_logic;
    z        : out std_logic_vector(sig_width + exp_width downto 0);
    status   : out std_logic_vector(7 downto 0);
    complete : out std_logic
  );

end DW_fp_div_seq;


