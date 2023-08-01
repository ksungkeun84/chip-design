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
-- DesignWare_version: ee917c4d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Pipelined divider entity
--
--      Parameters      Valid Values    Description
--      ==========      =========       ===========  
--      width           >= 1            default: 2
--                                      Word length of a
--
--      tc_mode         0 to 1          default: 0
--                                      Two's complement control
--                                        0 => unsigned
--                                        1 => two's complement
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
--                                       4 => preferred isolation style: 'or'
--
--
--      Input Ports     Size            Description
--      ===========     ====            ============
--      clk             1               Clock 
--      rst_n           1               Reset, active low
--      en              1               Load enable, active low 
--      a               width           radicand 
--      
--      Output Ports     Size            Description
--      ===========     ====            ============--      
--      root            int(width+1)/2) square root of a
--
--      
-- MODIFIED:
--            DLL  02/04/08   Enhanced abstract and added "op_iso_mode" parameter
--                            and related code.
--
--            DLL  11/14/05   Changed value of 'num_stages' parameter in
--                            the abstract "Valid Values" comments
--
--
-------------------------------------------------------------------------------
 
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_sqrt_pipe is

  generic (
    width       : positive := 2;                --  radicand word width
    tc_mode     : natural  := 0;                -- '0' : unsigned, '1' : 2's compl.
    num_stages  : positive := 2;                -- number of pipeline stages
    stall_mode  : natural  := 1;    -- '0' : non-stallable, '1' : stallable
    rst_mode    : natural  := 1;    -- '0' : none, '1' : async, '2' : sync
    op_iso_mode : natural  := 0);   -- operand isolation selection

  port (
    clk   : in  std_logic;            -- register clock
    rst_n : in  std_logic;            -- register reset
    en    : in  std_logic;            -- register enable
    a     : in  std_logic_vector(width-1 downto 0);  -- radicand
    root  : out std_logic_vector((width+1)/2-1 downto 0));  -- square root

end DW_sqrt_pipe;
