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
-- AUTHOR:    Doug Lee    8/23/05
--
-- VERSION:   VHDL Simulation Model for DW_gray_sync
--
-- DesignWare_version: bfd00793
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Gray Coded Synchronizer
--
--           This converts binary counter values to gray-coded values in the source domain
--           which then gets synchronized in the destination domain.  Once in the destination
--           domain, the gray-coded values are decoded back to binary values and presented
--           to the output port 'count_d'.  In the source domain, two versions of binary
--           counter values, count_s and offset_count_s, are output to give reference to
--           current state of the counters in, relative and absolute terms, respectively.
--
--              Parameters:         Valid Values
--              ==========          ============
--              width               [ 1 to 1024: width of count_s, offset_count_s and count_d ports
--                                    default: 8 ]
--              offset              [ 0 to (2**(width-1) - 1): offset for non integer power of 2
--                                    default: 0 ]
--              reg_count_d         [ 0 or 1: registering of count_d output
--                                    default: 1
--                                    0 = count_d output is unregistered
--                                    1 = count_d output is registered ]
--              f_sync_type         [ 0 to 4: mode of synchronization
--                                    default: 2
--                                    0 = single clock design, no synchronizing stages implemented,
--                                    1 = 2-stage synchronization w/ 1st stage neg-edge & 2nd stage pos-edge capturing,
--                                    2 = 2-stage synchronization w/ both stages pos-edge capturing,
--                                    3 = 3-stage synchronization w/ all stages pos-edge capturing
--                                    4 = 4-stage synchronization w/ all stages pos-edge capturing ]
--              tst_mode            [ 0 to 2: latch insertion for testing purposes
--                                    default: 0
--                                    0 = no hold latch inserted,
--                                    1 = insert hold 'latch' using a neg-edge triggered register
--                                    2 = insert hold 'latch' using active low latch ]
--              verif_en            [ 0, 1, or 4: verification mode
--                                    default: 1
--                                    0 = no sampling errors inserted,
--                                    1 = sampling errors are randomly inserted with 0 or up to 1 destination clock cycle delays
--                                    4 = sampling errors are randomly inserted with 0 or up to 0.5 destination clock cycle delays ]
--              pipe_delay          [ 0 to 2: pipeline bin2gray result
--                                    default: 0
--                                    0 = only re-timing register of bin2gray result to destination domain
--                                    1 = one additional pipeline stage of bin2gray result to destination domain
--                                    2 = two additional pipeline stages of bin2gray result to destination domain ]
--              reg_count_s         [ 0 or 1: registering of count_s output
--                                    default: 1
--                                    0 = count_s output is unregistered
--                                    1 = count_s output is registered ]
--              reg_offset_count_s  [ 0 or 1: registering of offset_count_s output
--                                    default: 1
--                                    0 = offset_count_s output is unregistered
--                                    1 = offset_count_s output is registered 
--
--              Input Ports:    Size     Description
--              ===========     ====     ===========
--              clk_s           1 bit    Source Domain Input Clock
--              rst_s_n         1 bit    Source Domain Active Low Async. Reset
--              init_s_n        1 bit    Source Domain Active Low Sync. Reset
--              en_s            1 bit    Source Domain enable that advances binary counter
--              clk_d           1 bit    Destination Domain Input Clock
--              rst_d_n         1 bit    Destination Domain Active Low Async. Reset
--              init_d_n        1 bit    Destination Domain Active Low Sync. Reset
--              test            1 bit    Test input
--
--              Output Ports    Size     Description
--              ============    ====     ===========
--              count_s         M bit    Source Domain binary counter value
--              offset_count_s  M bits   Source Domain binary counter offset value
--              count_d         M bits   Destination Domain binary counter value
--
--                Note: (1) The value of M is equal to the 'width' parameter value
--
--
-- MODIFIED:
--            8/01/11  DLL   Changed range of values for tst_mode to have upper limit of 2.
--
--            7/10/06  DLL   Added parameter 'pipe_delay' that allows up to 2 additional
--                           register delays of the binary to gray code result from
--                           the source to destination domain.
--
--            7/21/06  DLL   Added parameter 'reg_count_s' which allows for registered 
--                           or unregistered 'count_s'.
--
--            8/1/06   DLL   Added parameter 'reg_offset_count_s' which allows for registered
--                           or unregistered 'offset_count_s'.
--
--            11/7/06  DLL   Modified functionality to support f_sync_type = 4
--
-------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_gray_sync is
   generic (
     width              : POSITIVE  := 8;   -- input width
     offset             : NATURAL   := 0;  -- offset for non-integer powers of 2
     reg_count_d        : NATURAL   := 1;      -- register count_d output
     f_sync_type        : NATURAL := 2;
     tst_mode           : NATURAL   := 0;
     verif_en           : NATURAL   := 1;      -- selection of the number of missampling stages
     pipe_delay         : NATURAL   := 0;
     reg_count_s        : NATURAL   := 1;      -- register count_s output
     reg_offset_count_s : NATURAL   := 1       -- register offset_count_s output
   );

   port (
     clk_s           : in std_logic;
     rst_s_n         : in std_logic;
     init_s_n        : in std_logic;
     en_s            : in std_logic;
     count_s         : out std_logic_vector(width-1 downto 0);
     offset_count_s  : out std_logic_vector(width-1 downto 0);

     clk_d           : in std_logic;
     rst_d_n         : in std_logic;
     init_d_n        : in std_logic;
     count_d         : out std_logic_vector(width-1 downto 0);

     test            : in std_logic
   );
end DW_gray_sync;
