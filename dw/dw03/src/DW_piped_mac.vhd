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
-- AUTHOR:    Doug Lee    Feb 23, 2006
--
-- VERSION:   Entity
--
-- DesignWare_version: b99a1215
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Pipelined Multiply and Accumulate Entity
--
--           This receives to operands that get multiplied and
--           accumulated.  The operation is configurable to be
--           pipelined.  Also, includes pipeline management.
--
--
--              Parameters      Valid Values   Description
--              ==========      ============   ===========
--              a_width           1 to 1024    default: 8
--                                             Width of 'a' input
--
--              b_width           1 to 1024    default: 8
--                                             Width of 'a' input
--
--              acc_width         2 to 2048    default: 16
--                                             Width of 'a' input
--                                               Must be >= (a_width + b_width)
--
--              tc                  0 or 1     default: 0
--                                             Twos complement control
--                                               0 => unsigned
--                                               1 => signed
--
--              pipe_reg            0 to 7     default: 0
--                                             Pipeline register stages
--                                               0 => no pipeline register stages inserted
--                                               1 => pipeline stage0 inserted
--                                               2 => pipeline stage1 inserted
--                                               3 => pipeline stages 0 and 1 inserted
--                                               4 => pipeline stage2 pipeline inserted
--                                               5 => pipeline stages 0 and 2 pipeline inserted
--                                               6 => pipeline stages 1 and 2 inserted
--                                               7 => pipeline stages 0, 1, and 2 inserted
--
--              id_width          1 to 1024    default: 1
--                                             Width of 'launch_id' and 'arrive_id' ports
--
--              no_pm               0 or 1     default: 0
--                                             Pipeline management included control
--                                               0 => DW_pipe_mgr connected to pipeline
--                                               1 => DW_pipe_mgr bypassed
--
--              op_iso_mode         0 to 4     default: 0
--                                             Type of operand isolation
--                                               0 => Follow intent defined by Power Compiler user setting
--                                               1 => no operand isolation
--                                               2 => 'and' gate operand isolaton
--                                               3 => 'or' gate operand isolation
--                                               4 => preferred isolation style: 'and' gate
--
--
--              Input Ports:    Size           Description
--              ===========     ====           ===========
--              clk             1 bit          Input Clock
--              rst_n           1 bit          Active Low Async. Reset
--              init_n          1 bit          Active Low Sync. Reset
--              clr_acc_n       1 bit          Actvie Low Clear accumulate results
--              a               a_width bits   Multiplier
--              b               b_width bits   Multiplicand
--              launch          1 bit          Start a multiply and accumulate with a and b
--              launch_id       id_width bits  Identifier associated with 'launch' assertion
--              accept_n        1 bit          Downstream logic ready to use 'acc' result (active low)
--
--              Output Ports    Size           Description
--              ============    ====           ===========
--              acc             acc_width bits Multiply and accumulate result
--              arrive          1 bit          Valid multiply and accumulate result
--              arrive_id       id_width bits  launch_id from originating launch that produced acc result
--              pipe_full       1 bit          Upstream notification that pipeline is full
--              pipe_ovf        1 bit          Status Flag indicating pipe overflow
--              push_out_n      1 bit          Active Low Output used with FIFO (optional)
--              pipe_census     M bits         Output bus indicating the number of pipe stages currently occupied
--
--                Note: (1) The value of M is ceiling log2 of (one plus the maximum pipeline stages)
--                          where the maximum number of pipeline stages is defined by
--                          the 'pipe_reg' value (and the number of stages in the multiplier)
--
--
-- MODIFIED:
--            02/06/08  DLL  Enhanced abstract and added 'op_iso_mode' parameter
--                           and related code
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_piped_mac is
   generic (
     a_width     : POSITIVE := 8;  -- input 'a' width, at least 1
     b_width     : POSITIVE := 8;  -- input 'b' width, at least 1
     acc_width   : POSITIVE  := 16; -- output 'acc' width, at least 2 to something large
     tc          : NATURAL      := 0;  -- twos complement
     pipe_reg    : NATURAL      := 0;  -- pipeline register insertion
     id_width    : POSITIVE  := 1;
     no_pm       : NATURAL      := 0;  -- no DW_pipe_mgr configuration
     op_iso_mode : NATURAL      := 0   -- operand isolation selection
   );

   port (
     clk         : in std_logic;
     rst_n       : in std_logic;
     init_n      : in std_logic;
     clr_acc_n   : in std_logic;
     a           : in std_logic_vector(a_width-1 downto 0);
     b           : in std_logic_vector(b_width-1 downto 0);
     acc         : out std_logic_vector(acc_width-1 downto 0);
     launch      : in std_logic;
     launch_id   : in std_logic_vector(id_width-1 downto 0);
     pipe_full   : out std_logic;
     pipe_ovf    : out std_logic;
     accept_n    : in std_logic;
     arrive      : out std_logic;
     arrive_id   : out std_logic_vector(id_width-1 downto 0);
     push_out_n  : out std_logic;
     pipe_census : out std_logic_vector(2 downto 0)
   );
end DW_piped_mac;
