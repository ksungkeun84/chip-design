--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1992 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Jay Zhu	Sept 15, 1999
--
-- VERSION:   Synthetic Architecture
--
-- DesignWare_version: f9aa818a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
 
architecture sim of DW_8b10b_unbal is
	

-- pragma translate_off

------------------------------------------------------------------------

type	IDX_TBL_T is array (0 to 7) of integer;

constant idx_tbl : IDX_TBL_T := (
	0,
	1,
	1,
	1,
	0,
	1,
	1,
	0
		);

type 	UNBAL_TBL_T is array (0 to 1) of std_logic_vector(0 to 31);
constant unbal_tbl : UNBAL_TBL_T := (
	"00010111011111100111111001101000",
	"11101000100000011000000110010111"
		);

function DWF_8b10b_unbal(
		data_in:	std_logic_vector(7 downto 0);
		k_char:		std_logic
		)
		return	std_logic is
	variable unbal : std_logic;
begin
	if any_unknown(data_in & k_char)=1 then
	  unbal := 'X';
	elsif k_char = '0' then
	  unbal := unbal_tbl(idx_tbl(CONV_INTEGER(UNSIGNED(data_in(7 downto 5)))))
			(CONV_INTEGER(UNSIGNED(data_in(4 downto 0))));
	elsif k_char = '1' then
	  if k28_5_only = 0 then
	    case data_in is
	      when "00011100"
	         | "10011100"
	         | "11111100"
	         | "11110111"
	         | "11111011"
	         | "11111101"
	         | "11111110"
		 =>
		unbal := '0';
	      when "00111100"
	         | "01011100"
	         | "01111100"
	         | "10111100"
	         | "11011100"
		 =>
		unbal := '1';
	      when others =>
		unbal := 'X';
		assert (1=0)
		  report "Warning: Invalid data on data_in of DW_8b10b_unbal when k28_5_only=0 and k_char=1."
		  severity WARNING;
		
	    end case;
	  else
	    unbal := '1';
	  end if;
	end if;

	return unbal;

end DWF_8b10b_unbal;

-- pragma translate_on
begin
-- pragma translate_off

	unbal <= DWF_8b10b_unbal(data_in, k_char);

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_8b10b_unbal_cfg_sim of DW_8b10b_unbal is
 for sim
 end for; -- sim
end DW_8b10b_unbal_cfg_sim;
-- pragma translate_on
