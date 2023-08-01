--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    ps   Aug. 22, 1994
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 161f491e
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Three-Stage Pipelined Multiplier
--
-- MODIFIED : GN  Jan. 25, 1996
--            Move component from DW03 to DW02
--            Remove DW02_pipe_reg
--
--  11/04/15  RJK  Change pkg use from individual DW02 pkg to unified DWARE pkg
---------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_comp.all;
architecture sim of DW02_mult_3_stage is
	
  signal INTERNAL_PRODUCT, INTERNAL_PRODUCT1 : std_logic_vector(A_width+B_width-1 downto 0);
begin
-- pragma translate_off
   mult1 : DW02_mult 
      generic map ( A_width, B_width)
      port map ( A, B, TC, INTERNAL_PRODUCT);
   reg1_process: process
       begin
          wait until CLK'event and CLK = '1';
           INTERNAL_PRODUCT1 <= INTERNAL_PRODUCT;
           PRODUCT <= INTERNAL_PRODUCT1;
       end process;
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw02;

configuration DW02_mult_3_stage_cfg_sim of DW02_mult_3_stage is
 for sim
   for mult1 : DW02_mult use configuration dw02.DW02_mult_cfg_sim; end for;
 end for; -- sim
end DW02_mult_3_stage_cfg_sim;
-- pragma translate_on
