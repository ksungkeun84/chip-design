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
-- AUTHOR:    bdean
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: 2760149b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:   Data Synchronizer
--              Synchronizes data across clock boundaries
--
-- KNOWN BUGS: None
--
-- CHANGE LOG:
--  01/12/05   modified for DWBB bd
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity DW_data_sync is

 generic (
           width       :     natural := 8; -- default is byte
           pend_mode   :     natural := 1; -- use pending data buffer
           ack_delay   :     natural := 1; -- ack data transfer when captured
           f_sync_type :     natural             := 2; -- 2 pos syncs src -> dest (request)
           r_sync_type :     natural             := 2; -- 2 pos syncs dest -> src (ack)
           tst_mode    :     natural := 0; 
           verif_en    :     natural := 1; 
           send_mode   :     natural := 0  -- pulse mode type for pas
         ); 
 
port (
      clk_s           : in std_logic;
      rst_s_n         : in std_logic;
      init_s_n        : in std_logic;
      send_s          : in std_logic;
      data_s          : in std_logic_vector (width-1 downto 0);
      empty_s         : out std_logic;
      full_s          : out std_logic;
      done_s          : out std_logic;

      clk_d           : in std_logic;
      rst_d_n         : in std_logic;
      init_d_n        : in std_logic;
      data_avail_d    : out std_logic;
      data_d          : out std_logic_vector (width-1 downto 0);
      
      test            : in std_logic
      );

end DW_data_sync;
