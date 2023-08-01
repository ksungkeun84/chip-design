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
-- DesignWare_version: 7a937a79
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Data Bus Synchronizer without acknowledge
--
--
--           This synchronizer passes data values from the source domain to the destination domain.
--           Full feedback hand-shake is NOT used. So there is no busy or done status on in the source domain.
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ default : 8
--                                1 to 1024 : width of data_s and data_d ports ]
--              f_sync_type     [ default : 2
--                                0 = single clock design, no synchronizing stages implemented,
--                                1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                3 = 3-stage synchronization w/ all stages pos-edge capturing,
--                                4 = 4-stage synchronization w/ all stages pos-edge capturing ]
--              tst_mode        [ default : 0
--                                0 = no hold latch inserted,
--                                1 = insert hold 'latch' using a neg-edge triggered register ]
--              verif_en        [ default : 1
--                                0 = no sampling errors inserted,
--                                1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                2 = sampling errors are randomly inserted with 0, 0.5, 1 or 1.5 destination clock cycle delays
--                                3 = sampling errors are randomly inserted with 0, 1, 2, or 3 destination clock cycle delays
--                                4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
--              send_mode       [ default : 0 (send_s detection control)
--                                0 = every clock cycle of send_s asserted invokes
--                                    a data transfer to destination domain
--                                1 = rising edge transition of send_s invokes
--                                    a data transfer to destination domain
--                                2 = falling edge transition of send_s invokes
--                                    a data transfer to destination domain
--                                3 = every toggle transition of send_s invokes
--                                    a data transfer to destination domain ]
--
--
--              Input Ports:    Size     Description
--              ===========     ====     ===========
--              clk_s           1 bit    Source Domain Input Clock
--              rst_s_n         1 bit    Source Domain Active Low Async. Reset
--              init_s_n        1 bit    Source Domain Active Low Sync. Reset
--              send_s          1 bit    Source Domain Active High Send Request
--              data_s          N bits   Source Domain Data Input
--              clk_d           1 bit    Destination Domain Input Clock
--              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--              test            1 bit    Test input
--
--              Output Ports    Size     Description
--              ============    ====     ===========
--              data_avail_d    1 bit    Destination Domain Data Available Output
--              data_d          N bits   Destination Domain Data Output
--
--                Note: (1) The value of N is equal to the 'width' parameter value
--
--
--
-- MODIFIED:
--
--              DLL  11/15/06 Added 4-stage synchronization capability
--
--              DLL  6/8/06   Added send_mode parameter and functionality
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_data_sync_na is
   generic (
     width       : POSITIVE  := 8;
     f_sync_type : NATURAL  := 2;
     tst_mode    : NATURAL   := 0;
     verif_en    : NATURAL   := 1;
     send_mode   : NATURAL   := 0
   );

   port (
     clk_s     : in std_logic;
     rst_s_n   : in std_logic;
     init_s_n  : in std_logic;
     send_s    : in std_logic;
     data_s    : in std_logic_vector(width-1 downto 0);
     clk_d     : in std_logic;
     rst_d_n   : in std_logic;
     init_d_n  : in std_logic;
     test      : in std_logic;
     data_avail_d  : out std_logic;
     data_d    : out std_logic_vector(width-1 downto 0)
   );
end DW_data_sync_na;
