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
-- AUTHOR:    Bruce Dean                 July 9, 2004
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 46daab65
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT :
--           pulseack synchronizer based on RJK's verilog
--
-------------------------------------------------------------------------------
--      Parameters      Valid Values    Description
--      ==========      ============    ===========
--      reg_event         0 to 1        register output
--      reg_ack           0 to 1        register ack output
--      ack_delay         0 to 1        ack timing parameter
--      f_sync_type       0 to 4        number and type of flops s->d
--      r_sync_type       0 to 4        number and type of flops d-> s
--      tst_mode          0 to 2        test mode flop/latch insertion
--      verif_en          0 to 4        Missampling method control
--      pulse_mode        0 to 3        input trigger method
--
-------------------------------------------------------------------------------
library IEEE  ;
use IEEE.std_logic_1164.all ;

entity DW_pulseack_sync is
  generic (
    reg_event   :     NATURAL  := 1;
    reg_ack     :     NATURAL  := 1;
    ack_delay   :     NATURAL  := 1;
    f_sync_type :     NATURAL              := 2; 
    r_sync_type :     NATURAL              := 2; 
    tst_mode    :     NATURAL  := 0; 
    verif_en    :     NATURAL  := 1;
    pulse_mode  :     NATURAL  := 0 
    ); 
  port (

    clk_s    : in std_logic;  -- clock  for source domain
    rst_s_n  : in std_logic;  -- active low async. reset in clk_s domain
    init_s_n : in std_logic;  -- active low sync. reset in clk_s domain
    event_s  : in std_logic;  -- event pulseack  (active high event)
    ack_s    : out std_logic;   -- source domain event acknowledge output
    busy_s   : out std_logic;   -- source domain busy status output

    clk_d    : in  std_logic;  -- clock  for destination domain
    rst_d_n  : in  std_logic;  -- active low async. reset in clk_d domain
    init_d_n : in  std_logic;  -- active low sync. reset in clk_d domain
    event_d  : out std_logic;  -- event pulseack output (active high event)

    test     : in  std_logic  -- test mode
   );
end DW_pulseack_sync;

