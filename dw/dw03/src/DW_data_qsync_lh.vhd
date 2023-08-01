----------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2004 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean May 18 2006
--
-- VERSION:   Entity
--
-- DesignWare_version: 80853014
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
-- ABSTRACT: 
--           - 
--           - 
-- 
-- MODIFIED:
--
-------------------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
--
entity DW_data_qsync_lh is
  generic (
           width       :     natural := 8; -- default is byte
           clk_ratio   :     natural := 2; -- 
           reg_data_s  :     natural := 1; -- 
           reg_data_d  :     natural := 1; 
           tst_mode    :     natural := 0 
);
  port (
        clk_s           : in std_logic;
        rst_s_n         : in std_logic;
        init_s_n        : in std_logic;
        send_s          : in std_logic;
        data_s          : in std_logic_vector (width-1 downto 0);

        clk_d           : in std_logic;
        rst_d_n         : in std_logic;
        init_d_n        : in std_logic;
        data_avail_d    : out std_logic;
        data_d          : out std_logic_vector (width-1 downto 0);
      
        test            : in std_logic
      );
end DW_data_qsync_lh ;
