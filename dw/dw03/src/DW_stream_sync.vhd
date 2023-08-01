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
-- AUTHOR:    Doug Lee    Dec 1, 2005
--
-- VERSION:   Entity
--
-- DesignWare_version: 767058cb
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Data Stream Synchronizer Synthetic Model
--
--           This synchronizes an incoming data stream from a source domain
--           to a destination domain with a minimum amount of latency.
--
--       Parameters:     Valid Values    Description
--       ==========      ============    ===========
--       width            1 to 1024      default: 8
--                                       Width of data_s and data_d ports
--
--       depth            2 to 256       default: 4
--                                       Depth of FIFO
--
--       prefill_lvl     0 to depth-1    default: 0
--                                       number of FIFO locations filled before
--                                       transferring to destination domain ]
--
--       f_sync_type       0 to 4        default: 2
--                                       Forward Synchronization Type (Source to Destination Domains)
--                                         0 => no synchronization, single clock design
--                                         1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing
--                                         2 => 2-stage synchronization w/ both stages pos-edge capturing
--                                         3 => 3-stage synchronization w/ all stages pos-edge capturing
--                                         4 => 4-stage synchronization w/ all stages pos-edge capturing
--
--       reg_stat          0 or 1        default: 1
--                                       Register internally calculated status
--                                         0 => don't register internally calculated status
--                                         1 => register internally calculated status
--
--       tst_mode          0 or 2        default: 0
--                                       Insert neg-edge hold latch at front-end of synchronizers during "test"
--                                         0 => no hold latch inserted,
--                                         1 => insert hold 'latch' using a neg-edge triggered register
--                                         2 => insert hold latch using an active low latch
--
--        verif_en       0 to 4       Synchronization missampling control (Simulation verification)
--                                    Default value = 1
--                                    0 => no sampling errors modeled,
--                                    1 => when using the SIM_MS architecture, randomly insert 0 to 1 cycle delay
--                                    2 => when using the SIM_MS architecture, randomly insert 0 to 1.5 cycle delay
--                                    3 => when using the SIM_MS architecture, randomly insert 0 to 3 cycle delay
--                                    4 => when using the SIM_MS architecture, randomly insert 0 to 0.5 cycle delay
--
--       r_sync_type       0 to 4        default: 2
--                                       Reverse Synchronization Type (Destination to Source Domains)
--                                         0 => no synchronization, single clock design
--                                         1 => 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing
--                                         2 => 2-stage synchronization w/ both stages pos-edge capturing
--                                         3 => 3-stage synchronization w/ all stages pos-edge capturing
--                                         4 => 4-stage synchronization w/ all stages pos-edge capturing
--
--       clk_d_faster      0 to 15       default: 1
--                                       clk_d faster than clk_s by difference ratio
--                                         0        => Either clr_s or clr_d active with the other tied low at input
--                                         1 to 15  => ratio of clk_d to clk_s frequencies plus 1
--
--       reg_in_prog       0 or 1        default: 1
--                                       Register the 'clr_in_prog_s' and 'clr_in_prog_d' Outputs
--                                         0 => unregistered
--                                         1 => registered
--
--       Input Ports:    Size     Description
--       ===========     ====     ===========
--       clk_s           1 bit    Source Domain Input Clock
--       rst_s_n         1 bit    Source Domain Active Low Async. Reset
--       init_s_n        1 bit    Source Domain Active Low Sync. Reset
--       clr_s           1 bit    Source Domain Internal Logic Clear (reset)
--       send_s          1 bit    Source Domain Active High Send Request
--       data_s          N bits   Source Domain Data
--
--       clk_d           1 bit    Destination Domain Input Clock
--       rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--       init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--       clr_d           1 bit    Destination Domain Internal Logic Clear (reset)
--       prefill_d       1 bit    Destination Domain Prefill Control
--
--       test            1 bit    Test input
--
--       Output Ports    Size     Description
--       ============    ====     ===========
--       clr_sync_d      1 bit    Source Domain Clear
--       clr_in_prog_s   1 bit    Source Domain Clear in Progress
--       clr_cmplt_s     1 bit    Soruce Domain Clear Complete (pulse)
--
--       clr_in_prog_d   1 bit    Destination Domain Clear in Progress
--       clr_sync_d      1 bit    Destination Domain Clear (pulse)
--       clr_cmplt_d     1 bit    Destination Domain Clear Complete (pulse)
--       data_avail_d    1 bit    Destination Domain Data Available
--       data_d          N bits   Destination Domain Data
--       prefilling_d    1 bit    Destination Domain Prefillng Status
--
--           Note: The value of N is equal to the 'width' parameter value
--
--
--
-- MODIFIED:
--  07/26/11 DLL  Added comments for tst_mode = 2 and range to inlcude '2'.
--
--  10/20/06 DLL  Updated with new version of DW_reset_sync
--
--  11/15/06 DLL  Added 4-stage synchronization capability
--
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_stream_sync is
   generic (
     width        : POSITIVE  := 8;
     depth        : POSITIVE   := 4;
     prefill_lvl  : NATURAL    := 0;
     f_sync_type  : NATURAL  := 2;
     reg_stat     : NATURAL      := 1;
     tst_mode     : NATURAL      := 0;
     verif_en     : NATURAL      := 1;
     r_sync_type  : NATURAL  := 2;
     clk_d_faster : NATURAL     := 1;
     reg_in_prog  : NATURAL      := 1
   );

   port (
     clk_s         : in std_logic;
     rst_s_n       : in std_logic;
     init_s_n      : in std_logic;
     clr_s         : in std_logic;
     send_s        : in std_logic;
     data_s        : in std_logic_vector(width-1 downto 0);
     clr_sync_s    : out std_logic;
     clr_in_prog_s : out std_logic; 
     clr_cmplt_s   : out std_logic; 

     clk_d         : in std_logic;
     rst_d_n       : in std_logic;
     init_d_n      : in std_logic;
     clr_d         : in std_logic;
     prefill_d     : in std_logic;
     clr_in_prog_d : out std_logic; 
     clr_sync_d    : out std_logic;
     clr_cmplt_d   : out std_logic; 
     data_avail_d  : out std_logic;
     data_d        : out std_logic_vector(width-1 downto 0);
     prefilling_d  : out std_logic;

     test          : in std_logic
   );
end DW_stream_sync;
