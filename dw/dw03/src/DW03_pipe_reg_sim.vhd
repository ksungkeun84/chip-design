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
-- AUTHOR:    PS			Jan. 5, 1992
--
-- VERSION:   Simulation Architecture
--
-- DesignWare_version: 1b4f2c7b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Pipeline Register
--
-- MODIFIED: 
--           by Sitanshu Kumar 7th oct 96
--           The model was completely wrong, instead of pipeline it was simulating 
--           a delay element.
--           
--	     Rong 	Aug. 10,1999
--	     Add x-handling 
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
architecture sim of DW03_pipe_reg is
	
type intern_type is array (depth downto 0) of std_logic_vector(width-1 downto 0);
signal int : intern_type;
begin
-- pragma translate_off
  pipe_reg: process
  variable B_int: std_logic_vector(width-1 downto 0);
    begin
    -- if depth = 0 then no register exists, ie. its just a wire
    if depth = 0 then
      wait on A;
      B_int := TO_UX01(A);
     -- if depth > 0 then we have an edge triggered pipeline register
    elsif depth = 1 then
	wait until rising_edge(clk) ;
		B_int := TO_UX01(A);
    elsif depth > 1 then
	wait until rising_edge(clk) ;
		B_int := int(depth-2);
	for j in 2 to depth-1 loop 
		int(depth-j) <= int(depth-j-1);
	end loop ;
		int(0) <= TO_UX01(A);
	
    -- if depth < 0 then we have an error
    else
      assert depth >= 0
        report "parameter depth must be equal to or greater than 0"
	   severity Warning;
      wait;
    end if;
  B <= B_int;
  end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW03_pipe_reg_cfg_sim of DW03_pipe_reg is
 for sim
 end for; -- sim
end DW03_pipe_reg_cfg_sim;
-- pragma translate_on
