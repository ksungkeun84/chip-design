--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1998 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Sourabh Tandon               Dec. 4, '98
--
-- VERSION:   VHDL Entity File
--
-- NOTE:      This is a subentity.
--            This file is for internal use only.
--
-- DesignWare_version: fee91fd7
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Entity description for DW_Z_control_force.
--
-- MODIFIED:
--
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
 
entity DW_Z_control_force is
    port (TD    : in std_logic;
          TM    : in std_logic;
          TPE   : in std_logic; 
          DRVR  : out std_logic);
end;
