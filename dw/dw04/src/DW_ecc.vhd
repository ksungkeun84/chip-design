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
-- AUTHOR:    RJK                        July 9, 1996
--
-- VERSION:   Entity
--
-- DesignWare_version: 04c97c7b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Error Detection & Correction
--           parameterizable data size (4 <= "width" <= 502)
--           parameterizable # checkbits (5 <= "chkbits" <= 14)
--           parameterizable checkbit correction vs syndrome
--                           emission selection
--           datain      - input data
--           chkin       - input check bits
--           gen         - controls whether output check bits, chkout, are
--                         generated from data input bits, datain, or they are
--                         derived from input check bits, chkin (with possible
--                         correction applied)
--           correct_n   - control signal indicating whether or not to correct
--           dataout     - output data
--           chkout      - output check bits
--           err_multpl  - flag indicating multibit (i.e. uncorrectable) error
--           err_detect  - flag indicating occurance of error
--
-- MODIFIED:
--
--		RJK : extended range on widths (STAR 9000173367)
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
 
entity DW_ecc is
  generic(width: INTEGER;
          chkbits : INTEGER ;
	  synd_sel : INTEGER  );
  port(gen: in std_logic;
       correct_n: in std_logic;
       datain: in std_logic_vector(width-1 downto 0);
       chkin: in std_logic_vector(chkbits-1 downto 0);
       err_detect: out std_logic;
       err_multpl: out std_logic;
       dataout: out std_logic_vector(width-1 downto 0);
       chkout: out std_logic_vector(chkbits-1 downto 0));
end DW_ecc;

