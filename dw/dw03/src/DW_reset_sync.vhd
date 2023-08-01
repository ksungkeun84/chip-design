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
-- AUTHOR:    Doug Lee    Dec. 06, 2005
--
-- VERSION:   Entity
--
-- DesignWare_version: 8c6ec9d3
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Reset Sequence Synchronizer
--
--           This synchronizer orchestrates a synchronous reset sequence between the source
--           and destination domains.
--
--              Parameters:     Valid Values
--              ==========      ============
--              f_sync_type     default: 2
--                              Forward Synchronized Type (Source to Destination Domains)
--                                0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing
--              r_sync_type     default: 2
--                              Reverse Synchronization Type (Destination to Source Domains)
--                                0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing
--              clk_d_faster    default: 1
--                                This parameter is obsolete and its value is ignored.  However, for
--                                backward compatibility it is kept in place.
--              reg_in_prog     default: 1
--                              Register the 'clr_in_prog_s' and 'clr_in_prog_d' Outputs
--                                0 = unregistered
--                                1 = registered
--              tst_mode        default: 0
--                              Test Mode Setting
--                                0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register
--              verif_en          Synchronization missampling control (Simulation verification)
--                                Default value = 1
--                                0 => no sampling errors modeled,
--                                1 => when using the SIM_MS architecture, randomly insert 0 to 1 cycle delay
--                                2 => when using the SIM_MS architecture, randomly insert 0 to 1.5 cycle delay
--                                3 => when using the SIM_MS architecture, randomly insert 0 to 3 cycle delay
--                                4 => when using the SIM_MS architecture, randomly insert 0 to 0.5 cycle delay
--
--              Input Ports:    Size     Description
--              ===========     ====     ===========
--              clk_s           1 bit    Source Domain Input Clock
--              rst_s_n         1 bit    Source Domain Active Low Async. Reset
--              init_s_n        1 bit    Source Domain Active Low Sync. Reset
--              clr_s           1 bit    Source Domain Clear Initiated
--              clk_d           1 bit    Destination Domain Input Clock
--              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--              clr_d           1 bit    Destination Domain Clear Initiated
--              test            1 bit    Test input
--
--              Output Ports    Size     Description
--              ============    ====     ===========
--              clr_sync_s      1 bit    Source Domain Clear
--              clr_in_prog_s   1 bit    Source Domain Clear in Progress
--              clr_cmplt_s     1 bit    Source Domain Clear Complete (pulse)
--              clr_in_prog_d   1 bit    Destination Domain Clear in Progress
--              clr_sync_d      1 bit    Destination Domain Clear (pulse)
--              clr_cmplt_d     1 bit    Destination Domain Clear Complete (pulse)
--
--
-- MODIFIED: 
--              DLL   9-1-08   Removed unused "clr_max" parameter and changed the
--                             the description of "clk_d_faster" parameter.
--
--              DLL   8-21-06  Added parameters 'r_sync_type', 'clk_d_faster', 'reg_in_prog'.
--                             Added Destination outputs 'clr_in_prog_d' and 'clr_cmplt_d'
--                             and changed Source output 'clr_ack_s' to 'clr_cmplt_s'.
--
--              DLL   11-7-06  Modified functionality to support f_sync_type = 4 and
--                             r_sync_type = 4
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_reset_sync is
   generic (
     f_sync_type : NATURAL := 2;
     r_sync_type : NATURAL := 2;
     clk_d_faster: NATURAL  := 1;
     reg_in_prog : NATURAL   := 1;
     tst_mode    : NATURAL   := 0;
     verif_en    : NATURAL   := 1
   );

   port (
     clk_s         : in std_logic;
     rst_s_n       : in std_logic;
     init_s_n      : in std_logic;
     clr_s         : in std_logic;
     clr_sync_s    : out std_logic;
     clr_in_prog_s : out std_logic;
     clr_cmplt_s   : out std_logic;

     clk_d         : in std_logic;
     rst_d_n       : in std_logic;
     init_d_n      : in std_logic;
     clr_d         : in std_logic;
     clr_in_prog_d : out std_logic;
     clr_sync_d    : out std_logic;
     clr_cmplt_d   : out std_logic;

     test          : in std_logic
   );
end DW_reset_sync;
