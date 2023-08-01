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
-- AUTHOR:    Jay Zhu     October 20, 1998
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 8c211347
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Duplex Multiplier
--
--	Parameters		Valid Values
--	==========		============
--	width			>= 4
--	p1_width		2 to (width-2)
--
--	Input Ports	Size	Description
--	===========	====	===========
--	a		width	Input data
--	b		width	Input data
--	tc		1 bit	Two's complement select (active high)
--	dplx		1 bit	Duplex mode select (active high)
--
--	Output Ports	Size	Description
--	===========	====	===========
--	product		2*width	Output data
--
-- MODIFIED:
--
--  11/04/15  RJK  Change pkg use from individual DW02 pkg to unified DWARE pkg
--
--      RPH      Aug 21, 2002       
--              Added parameter checking and cleaned up 
---------------------------------------------------------------------------------
library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;

architecture sim of DW_mult_dx is
	
  
  constant p2_width     : INTEGER := width - p1_width;
  
  signal   duplex_prod  : std_logic_vector(2*width-1 downto 0);
  signal   simplex_prod : std_logic_vector(2*width-1 downto 0);

begin
-- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (width < 4) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 4)"
        severity warning;
    end if;
    
    if ( (p1_width < 2) OR (p1_width > width-2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter p1_width (legal range: 2 to width-2)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
    
-- Simplex mult 
  U1 :	DW02_mult
    generic map (
      A_width => width,
      B_width => width
      )
    port map (
      A => a,
      B => b,
      TC => tc,
      product => simplex_prod
      );
-- Duplex mult
  U2_1 :DW02_mult
    generic map (
      A_width => p1_width,
      B_width => p1_width
      )
    port map (
      A => a(p1_width-1 downto 0),
      B => b(p1_width-1 downto 0),
      TC => tc,
      product => duplex_prod(2*p1_width-1 downto 0)
      );
  U2_2:	DW02_mult
    generic map (
      A_width => p2_width,
      B_width => p2_width
      )
    port map (
      A => a(width-1 downto p1_width),
      B => b(width-1 downto p1_width),
      TC => tc,
      product => duplex_prod(2*width-1 downto
                             2*p1_width)
      );
  
  product <= std_logic_vector(simplex_prod) when dplx = '0' else
             std_logic_vector(duplex_prod) when dplx = '1' else
             (others => 'X');
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW_mult_dx_cfg_sim of DW_mult_dx is
 for sim
  for U1 :	DW02_mult use configuration dw02.DW02_mult_cfg_sim; end for;
  for U2_1 :DW02_mult use configuration dw02.DW02_mult_cfg_sim; end for;
  for U2_2:	DW02_mult use configuration dw02.DW02_mult_cfg_sim; end for;
 end for; -- sim
end DW_mult_dx_cfg_sim;
-- pragma translate_on
