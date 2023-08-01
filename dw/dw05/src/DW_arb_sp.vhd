--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rajeev Huralikoppi      June 07, 2000
--
-- VERSION:   Entity
--
-- DesignWare_version: 5502ea34
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT :
--	Arbiter based on Static priority scheme.
--      Parameters      Valid Values    Description
--      ==========      =========       ===========
--      n               {1 to 32}       Number of arb clients
--      park_mode       {0 to 1}        Enable/Disable parking of grant
--      park_index      {0 to 31}       Park the grant to default
--      output_mode     {0 to 1}        Enable/disable registered outputs   
--      
--      Input Ports   Size       Description
--      ===========   ====       ============
--      clk             1        Input clock
--      rst_n           1        Active low reset
--      init_n          1        Active low sync-reset
--      enable          1        Active high enable
--      request         n        Input request from clients
--      lock            n        lock in the grant to the current request
--      mask            n        Input to mask specific request
--      locked          1        Flag to indicate locked condition
--      parked          1        Flag to indicate that there are no
--                               requesting clients and the the grant
--                               of resources has defauled to park_index
--      granted         1        Flag to indicate that arb has
--                               granted the resource to one of the
--                               requesting clients
--      grant           n        Grant output 
--      grant_index     log2(n)  Index of the current grant
--
-- Modification history:
-------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;

entity DW_arb_sp is
  generic (
    n           :     natural := 4;
    park_mode   :     natural := 1;
    park_index  :     natural := 0;
    output_mode : natural := 1);
  port (
    clk         : in  std_logic;
    rst_n       : in  std_logic;
    init_n      : in  std_logic;
    enable      : in  std_logic;
    request     : in  std_logic_vector(n-1 downto 0);
    lock        : in  std_logic_vector(n-1 downto 0);
    mask        : in  std_logic_vector(n-1 downto 0);
    parked      : out std_logic;
    granted     : out std_logic;
    locked      : out std_logic;
    grant       : out std_logic_vector(n-1 downto 0);
    grant_index : out std_logic_vector(bit_width(n)-1 downto 0)
    );
end DW_arb_sp;
