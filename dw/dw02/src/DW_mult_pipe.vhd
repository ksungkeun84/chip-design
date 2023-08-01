--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2002 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rajeev Huralikoppi      April 2, 2002
--
-- VERSION:   Entity
--
-- DesignWare_version: 2150bcd6
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Pipelined multiplier entity
--
--      Parameters      Valid Values    Description
--      ==========      =========       ===========
--      a_width         >= 1            default: none
--                                      Word length of a
--
--      b_width         >= 1            default: none
--                                      Word length of b
--
--      num_stages      >= 2            default: 2
--                                      Number of pipelined stages
--
--      stall_mode      0 or 1          default: 1
--                                      Stall mode
--                                        0 => non-stallable
--                                        1 => stallable
--      
--      rst_mode        0 to 2          default: 1
--                                      Reset mode
--                                        0 => no reset
--                                        1 => asynchronous reset
--                                        2 => synchronous reset
--
--      op_iso_mode     0 to 4         default: 0
--                                     Type of operand isolation 
--                                       If 'stall_mode' is '0', this parameter is ignored and no isolation is applied
--                                       0 => Follow intent defined by Power Compiler user setting
--                                       1 => no operand isolation
--                                       2 => 'and' gate operand isolaton
--                                       3 => 'or' gate operand isolation
--                                       4 => preferred isolation style: 'and'
--
--
--      Input Ports     Size            Description
--      ===========     ====            ============ 
--      clk             1               Clock 
--      rst_n           1               Reset, active low
--      en              1               Load enable, active low
--      tc              1               2's complement control
--      a               a_width         Multiplier
--      b               b_width         Multiplicand
--      
--      product         a_width+b_width Product (a*b)
--      
-- MODIFIED:
--            DLL  02/01/08   Enhanced abstract and added "op_iso_mode" parameter
--                            and related code.
--
--            DLL  11/14/05   Changed value of 'num_stages' parameter in
--                            the abstract "Valid Values" comments
--
-------------------------------------------------------------------------------
  
library IEEE;
use IEEE.std_logic_1164.all;
 
entity DW_mult_pipe is

  generic (
    a_width       : positive;                      -- multiplier word width
    b_width       : positive;                      -- multiplicand word width
    num_stages    : positive := 2;                 -- number of pipeline stages
    stall_mode    : natural  := 1;     -- '0': non-stallable; '1': stallable
    rst_mode      : natural   := 1;    -- '0': none; '1': async; '2': sync
    op_iso_mode   : natural   := 0);   -- '0': apply Power Compiler user setting; '1': noop; '2': and; '3': or; '4' preferred style...'and'

  port (
    clk     : in  std_logic;          -- register clock
    rst_n   : in  std_logic;          -- register reset
    en      : in  std_logic;          -- register enable
    tc      : in  std_logic;          -- '0' : unsigned, '1' : signed
    a       : in  std_logic_vector(a_width-1 downto 0);  -- multiplier
    b       : in  std_logic_vector(b_width-1 downto 0);  -- multiplicand
    product : out std_logic_vector(a_width+b_width-1 downto 0));  -- product

end DW_mult_pipe;
