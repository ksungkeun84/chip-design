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
-- DesignWare_version: 4b28258e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT :
--
-------------------------------------------------------------------------------
--      Parameters      Valid Values    Description
--      ==========      ============    ===========
--      reg_event         0/1           register outputs
--      f_sync_type       0-4           number and type of flops
--      tst_mode          0-2           test mode flop/latch insertion
--      verif_en          0-4           num/type of sampling errors for sim
--      pulse_mode        0-3           pulse input type
--
-------------------------------------------------------------------------------
library IEEE  ;
use IEEE.std_logic_1164.all ;

entity DW_pulse_sync is
  generic (
    reg_event   :     natural  := 1;
    f_sync_type :     natural              := 2; 
    tst_mode    :     natural  := 0; 
    verif_en    :     natural  := 1; 
    pulse_mode  :     natural  := 0 
    ); 
  port (

    clk_s    : in std_logic;  -- clock  for source domain
    rst_s_n  : in std_logic;  -- active low async. reset in clk_s domain
    init_s_n : in std_logic;  -- active low sync. reset in clk_s domain
    event_s  : in std_logic;  -- event pulse  (active high event)

    clk_d    : in  std_logic;  -- clock  for destination domain
    rst_d_n  : in  std_logic;  -- active low async. reset in clk_d domain
    init_d_n : in  std_logic;  -- active low sync. reset in clk_d domain
    event_d  : out std_logic;  -- event pulse output (active high event)

    test     : in  std_logic   -- test mode

    );
end DW_pulse_sync;

