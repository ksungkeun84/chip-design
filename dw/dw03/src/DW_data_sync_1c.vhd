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
-- AUTHOR:    Doug Lee    May 12, 2005
--
-- VERSION:   Entity
--
-- DesignWare_version: 9b1e70f0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Single Clock Data Bus Synchronizer 
--
--           This synchronizes incoming data into the destination domain
--           with a configurable number of sampling stages and consecutive
--           samples of stable data values.
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ 1 to 1024 ]
--              f_sync_type     [ 0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing,
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
--              filt_size       [ 1 to 8 : width of filt_d input port ]
--              tst_mode        [ 0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register ]
--              verif_en        [ 0 = no sampling errors inserted,
--                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                2 = sampling errors are randomly inserted with 0, 0.5, 1 or 1.5 destination clock cycle delays
--                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
--              
--              Input Ports:    Size     Description
--              ===========     ====     ===========
--              clk_d           1 bit    Destination Domain Input Clock
--              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--		init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--              data_s          N bits   Source Domain Data Input
--              filt_d          M bits   Destination Domain filter defining the number of clk_d cycles required to declare stable data
--              test            N bits   Test input
--
--              Output Ports    Size     Description
--              ============    ====     ===========
--              data_avail_d    1 bit    Destination Domain Data Available Output
--              data_d          N bits   Destination Domain Data Output
--              max_skew_d      M+1 bits Destination Domain maximum skew detected between bits for any data_s bus transition
--
--                Note: (1) The value of M is equal to the 'filt_size' parameter value
--                      (2) The value of N is equal to the 'width' parameter value
--
--
-- MODIFIED: 
--
--              DLL  11/15/06 Added 4-stage synchronization capability
--
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_data_sync_1c is
   generic (
     width       : POSITIVE  := 8;  -- input width
     f_sync_type : NATURAL := 2;
     filt_size   : POSITIVE  := 1;
     tst_mode    : NATURAL  := 0;
     verif_en    : NATURAL  := 2   -- selection of the number of missampling stages
   );

   port (
     clk_d     : in std_logic;
     rst_d_n   : in std_logic;
     init_d_n  : in std_logic;
     data_s    : in std_logic_vector(width-1 downto 0);
     filt_d    : in std_logic_vector(filt_size-1 downto 0);
     test      : in std_logic;
     data_avail_d  : out std_logic;
     data_d    : out std_logic_vector(width-1 downto 0);
     max_skew_d    : out std_logic_vector(filt_size downto 0)
   );
end DW_data_sync_1c;
