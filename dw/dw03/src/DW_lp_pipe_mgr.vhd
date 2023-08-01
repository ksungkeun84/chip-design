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
-- AUTHOR:    Doug Lee    Feb 22, 2006
--
-- VERSION:   Entity
--
-- DesignWare_version: a469a153
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
--  ABSTRACT: Pipeline Manager Entity
--
--       This component tracks the activity in the pipeline
--       throttled by 'launch' and 'accept_n' inputs.  Active
--       launched transactions are allowed to fill the pipeline
--       when the downstream logic is not accepting new arrivals.
--
--  Parameters:     Valid Range    Default Value
--  ==========      ===========    =============
--  stages          1 to 1023          2
--  id_width        1 to 1024          2
--
--
--  Ports       Size    Direction    Description
--  =====       ====    =========    ===========
--  clk         1 bit     Input      Clock Input
--  rst_n       1 bit     Input      Async. Reset Input, Active Low
--  init_n      1 bit     Input      Sync. Reset Input, Active Low
--
--  launch      1 bit     Input      Active High Control input to lauche data into pipe
--  launch_id  id_width   Input      ID tag for data being launched (optional)
--  pipe_full   1 bit     Output     Status Flag indicating no slot for new data
--  pipe_ovf    1 bit     Output     Status Flag indicating pipe overflow
--
--  pipe_en_bus stages    Output     Bus of enables (one per pipe stage), Active High
--
--  accept_n    1 bit     Input      Flow Control Input, Active Low
--  arrive      1 bit     Output     Data Available output
--  arrive_id  id_width   Output     ID tag for data that's arrived (optional)
--  push_out_n  1 bit     Output     Active Low Output used with FIFO (optional)
--  pipe_census M bits    Output     Output bus indicating the number
--                                   of pipe stages currently occupied
--
--    Note: The value of M is equal to the ceil(log2(stages+1)).
--
-- MODIFIED:
--     DLL   9-13-07  Changed name from DW_pipe_mgr
--
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_lp_pipe_mgr is
   generic (
     stages      : POSITIVE  := 2;  -- number of pipeline stages
     id_width    : POSITIVE  := 2   -- input launch_id width
   );


   port (
     clk         : in std_logic;
     rst_n       : in std_logic;
     init_n      : in std_logic;
     launch      : in std_logic;
     launch_id   : in std_logic_vector(id_width-1 downto 0);
     pipe_full   : out std_logic;
     pipe_ovf    : out std_logic;
     pipe_en_bus : out std_logic_vector(stages-1 downto 0);
     accept_n    : in std_logic;
     arrive      : out std_logic;
     arrive_id   : out std_logic_vector(id_width-1 downto 0);
     push_out_n  : out std_logic;
     pipe_census : out std_logic_vector(bit_width(stages+1)-1 downto 0)
   );
end DW_lp_pipe_mgr;
