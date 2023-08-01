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
-- AUTHOR:    Doug Lee    Mar. 18, 2005
--
-- VERSION:   Entity
--
-- DesignWare_version: 2f8bb2e5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Fundamental Synchronizer
--
--           This synchronizes incoming data into the destination domain
--           with a configurable number of sampling stages.
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ 1 to 1024 ]
--              f_sync_type     [ 0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
--              tst_mode        [ 0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register
--                                2 = reserved (functions same as tst_mode=0 ]
--              verif_en        [ 0 = no sampling errors inserted,
--                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                2 = sampling errors are randomly inserted with 0, 0.5, 1, or 1.5 destination clock cycle delays
--                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
--              
--              Input Ports:    Size    Description
--              ===========     ====    ===========
--              clk_d           1 bit   Destination Domain Input Clock
--              rst_d_n         1 bit   Destination Domain Active Low Async. Reset
--		init_d_n        1 bit   Destination Domain Active Low Sync. Reset
--              data_s          N bits  Source Domain Data Input
--              test            N bits  Test input
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              data_d          N bits  Destination Domain Data Output
--
--                Note: the value of N is equal to the 'width' parameter value
--
--
-- MODIFIED: 
--              DLL   8-8-11   Added tst_mode=2 (not a functional change)
--
--              DLL   11-7-06  Modified functionality to support f_sync_type = 4
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_sync is
   generic (
     width       : POSITIVE  := 8;  -- input width
     f_sync_type : NATURAL := 2;
     tst_mode    : NATURAL   := 0;
     verif_en    : NATURAL   := 1   -- selection of the number of missampling stages
   );

   port (
     clk_d     : in std_logic;
     rst_d_n   : in std_logic;
     init_d_n  : in std_logic;
     data_s    : in std_logic_vector(width-1 downto 0);
     test      : in std_logic;
     data_d    : out std_logic_vector(width-1 downto 0)
   );
end DW_sync;
