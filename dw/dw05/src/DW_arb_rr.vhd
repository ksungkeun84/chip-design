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
-- AUTHOR:    Bruce Dean      July 25, 2006
--
-- VERSION:   Entity
--
-- DesignWare_version: 6347b9c9
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT :
--	Arbiter  First-Come-First-Served arbitraton schemes.
--      Parameters      Valid Values    Description
--      ==========      =========       ===========
--      n               {2 to 256}       Number of arb clients
--      output_mode     {0 to 1}        Registered or unregistered outputs    
--      index_mode      {0 to 2}        Index Output Mode
--      
--      Input Ports   Size              Description
--      ===========   ====              ============
--      clk             1               Input clock
--      rst_n           1               Active low reset
--      init_n          1               Active low sync-reset
--      enable          1               Active high enable
--      request         n               Input request from clients
--      mask            n bits          Setting mask(i) high will disable request(i)
--      
--      Output Ports   Size              Description
--      ===========   ====              ============  
--      granted         1               Flag to indicate that arb has
--                                      granted the resource to one of the
--                                      requesting clients
--      grant           n               Grant output    
--      grant_index     m               Index of the current grant
--
--      Where m = ceil(log2(n)) when index_mode=0 or index_mod=2 while
--            m = ceil(log2(n+1)) ehnd index_mode=1
--
-- Modification history:
--
--    RJK - 10/01/12
--    Enhancement that adds a new parameter to control the operation
--    of the grant_index output.
-------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;

entity DW_arb_rr is
  generic (
    n           : natural  := 4;
    output_mode : natural    := 1;
    index_mode  : natural    := 0);
  port (
    clk         : in  std_logic;
    rst_n       : in  std_logic;
    init_n      : in  std_logic;
    enable      : in  std_logic;
    request     : in  std_logic_vector(n-1 downto 0);
    mask        : in  std_logic_vector(n-1 downto 0);
    granted     : out std_logic;
    grant       : out std_logic_vector(n-1 downto 0);
    grant_index : out std_logic_vector(bit_width(n+(index_mode mod 2))-1 downto 0)
    );
end DW_arb_rr;




