--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1996 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Suzanne Skracic/RPH   July 9, 1996/May 17, 2002
--
-- VERSION:   VHDL Entity File
--
-- DesignWare_version: b88a7f13
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  TAP Controller with usercode support
--           
--
-- MODIFIED:
--   Suzanne Skracic on Oct. 3, 1996
--	Removing reset_mode parameter.
--
--   Sourabh Tandon Feb., 1998
--      Adding sync_capture_en and sync_update_en output ports.
--
--   Rajeev P Huralikoppi  May 2002
--      This is a new component derived from the DW_tap component
--      with additional parameters/ports to support USERCODE and
--      external ports  to support device identity register programming
--      with recompiling. (STARs 113898, 121365, 131993 )
--
--   RJK  12/16/2016
--      Adding tst_mode parameter to allow users NOT to use "test" input
--      (STAR 9001134192)
--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_tap_uc is
  generic(
    width         : INTEGER ;
    id            : INTEGER           := 0;
    idcode_opcode : INTEGER  := 1;
    version       : INTEGER          := 0;
    part          : INTEGER       := 0;
    man_num       : INTEGER        := 0;
    sync_mode     : INTEGER           := 0;
    tst_mode      : INTEGER           := 1);

  port (
    tck             : in  std_logic;
    trst_n          : in  std_logic;
    tms             : in  std_logic;
    tdi             : in  std_logic;
    so              : in  std_logic;
    bypass_sel      : in  std_logic;
    sentinel_val    : in  std_logic_vector(width-2 downto 0);
    
    -- Signals to support USERCODE
    device_id_sel   : in  std_logic;
    user_code_sel   : in  std_logic;
    user_code_val   : in  std_logic_vector(31 downto 0);
    
    -- Signals to support Device ID via input port
    ver             : in  std_logic_vector(3 downto 0);
    ver_sel         : in  std_logic;
    part_num        : in  std_logic_vector(15 downto 0);
    part_num_sel    : in  std_logic;
    mnfr_id         : in  std_logic_vector(10 downto 0);
    mnfr_id_sel     : in  std_logic;
    
    clock_dr        : out std_logic;
    shift_dr        : out std_logic;
    update_dr       : out std_logic;
    tdo             : out std_logic;
    tdo_en          : out std_logic;
    tap_state       : out std_logic_vector(15 downto 0);
    instructions    : out std_logic_vector(width-1 downto 0);
    sync_capture_en : out std_logic;
    sync_update_dr  : out std_logic;
    test            : in  std_logic);
end DW_tap_uc;
