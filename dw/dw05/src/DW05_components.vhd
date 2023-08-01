--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Derived From Entity Files
--
-- VERSION:   Components package file for DW05_components
--
-- DesignWare_version: 080396c5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;

library DWARE;
use DWARE.DWpackages.all;

package DW05_components is


  -- Content from file, DW_arb_2t.vhdpp

  component DW_arb_2t
  generic (
    n           : natural := 4;
    p_width     : natural := 2;
    park_mode   : natural := 1;
    park_index  : natural := 0;
    output_mode : natural := 1);
    
  port (
    clk         : in  std_logic;
    rst_n       : in  std_logic;
    init_n      : in  std_logic;
    enable      : in  std_logic;
    request     : in  std_logic_vector(n-1 downto 0);
    prior       : in  std_logic_vector (p_width*n-1 downto 0);
    lock        : in  std_logic_vector(n-1 downto 0);
    mask        : in  std_logic_vector(n-1 downto 0);
    parked      : out std_logic;
    granted     : out std_logic;
    locked      : out std_logic;
    grant       : out std_logic_vector(n-1 downto 0);
    grant_index : out std_logic_vector(bit_width(n)-1 downto 0)
    );
  end component;


  -- Content from file, DW_arb_dp.vhdpp

  component DW_arb_dp
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
    prior       : in  std_logic_vector ((bit_width(n)*n-1) downto 0);
    lock        : in  std_logic_vector(n-1 downto 0);
    mask        : in  std_logic_vector(n-1 downto 0);
    parked      : out std_logic;
    granted     : out std_logic;
    locked      : out std_logic;
    grant       : out std_logic_vector(n-1 downto 0);
    grant_index : out std_logic_vector(bit_width(n)-1 downto 0)
    );
  end component;


  -- Content from file, DW_arb_fcfs.vhdpp

  component DW_arb_fcfs
  generic (
    n           : natural := 4;
    park_mode   : natural := 1;
    park_index  : natural := 0;
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
  end component;


  -- Content from file, DW_arb_rr.vhdpp

  component DW_arb_rr
  generic (
    n           : natural range 2 to 256 := 4;
    output_mode : natural range 0 to 1   := 1;
    index_mode  : natural range 0 to 2   := 0);
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
  end component;


  -- Content from file, DW_arb_sp.vhdpp

  component DW_arb_sp
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
  end component;


end DW05_components;
