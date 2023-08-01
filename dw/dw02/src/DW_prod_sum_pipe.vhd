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
-- AUTHOR:    Rajeev Huralikoppi      Jan 2, 2002
--
-- VERSION:   Entity
--
-- DesignWare_version: b1cb5790
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Pipelined Sum of Products Entity File
--
--           This receives two set of 'concatenated' operands that result
--           in a summation from a set of products that can be pipelined.
--
--   Parameters      Valid Values   Description
--   ==========      ============   ===========  
--   a_width           >= 1         default: 2
--                                  Width of 'a' operand
--
--   b_width           >= 1         default: 2
--                                  Width of 'b' operand
--
--   num_inputs        >= 1         default: 2
--                                  Number of inputs each in 'a' and 'b'
--
--   sum_width         >= 2         default: 5
--                                  Word length of SUM
--
--   num_stages        >= 2         default: 2
--                                  Number of pipelined stages
--
--   stall_mode       0 or 1        default: 1
--                                  Stall mode
--                                    0 => non-stallable
--                                    1 => stallable
--
--   rst_mode         0 to 2        default: 1
--                                  Control asynchronous or synchronous reset
--                                  behavior of rst_n
--                                    0 => no reset
--                                    1 => asynchronous reset
--                                    2 => synchronous reset
--
--   op_iso_mode      0 to 4        default: 0
--                                  Type of operand isolation
--                                    If 'stall_mode' is '0', this parameter is ignored and no isolation is applied
--                                    0 => Follow intent defined by Power Compiler user setting
--                                    1 => no operand isolation
--                                    2 => 'and' gate operand isolaton
--                                    3 => 'or' gate operand isolation
--                                    4 => preferred isolation style: 'and'
--
--
--      Input Ports     Size            Description
--      ===========     ====            ============
--      clk             1 bit           Clock 
--      rst_n           1 bit           Reset, active low
--      tc              1 bit           2's complement control 
--      en              1 bit           Load enable, active low 
--      a               M bits          Multiplier
--      b               N bits          Multiplicand
--
--      Output Ports    Size            Description
--      ============    ====            ============
--      sum             S bits          Sum
--
--     Note: M is "a_width x num_inputs"
--     Note: N is "b_width x num_inputs"
--     Note: S is "sum_width" parameter setting
--      
-- MODIFIED:
--            DLL  02/05/08   Enhanced abstract and added 'op_iso_mode' parameter
--
--            DLL  11/14/05   Changed value of 'num_stages' parameter in
--                            the abstract "Valid Values" comments
--
-------------------------------------------------------------------------------
 
library IEEE;
use IEEE.std_logic_1164.all;
 
entity DW_prod_sum_pipe is

  generic (
    a_width      : positive := 2;              -- multiplier word width
    b_width      : positive := 2;              -- multiplicand word width
    num_inputs   : positive := 2;              -- number of inputs
    sum_width    : positive := 5;              -- width of sum
    num_stages   : positive := 2;              -- number of pipeline stages
    stall_mode   : natural  := 1;  -- '0' : non-stallable, '1' : stallable
    rst_mode     : natural  := 1;  -- '0' : none, '1' : async, '2' : sync
    op_iso_mode  : natural  := 0); -- '0': apply Power Compiler user setting; '1': noop; '2': and; '3': or; '4' preferred style...'and'

  port (
    clk   : in  std_logic;            -- register clock
    rst_n : in  std_logic;            -- register reset
    en    : in  std_logic;            -- register enable
    tc    : in  std_logic;            -- '0' : unsigned, '1' : signed
    a     : in  std_logic_vector(a_width*num_inputs-1 downto 0);  -- multiplier
    b     : in  std_logic_vector(b_width*num_inputs-1 downto 0);  -- multiplicand
    sum   : out std_logic_vector(sum_width-1 downto 0));  -- product

end DW_prod_sum_pipe;
