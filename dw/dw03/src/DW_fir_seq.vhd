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
-- AUTHOR:    Paul Scheidt	July 28, 1994
--
-- VERSION:   VHDL Entity File for DW_fir_seq
--
-- DesignWare_version: 182e8e90
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  DW_fir_seq is a FIR filter processor which computes
--            one filter tap per clock (clk) cycle
--            The filter coefficients are programmed by serially loading
--            the values into the coef_in port.
--
-- MODIFIED:  Zhijun (Jerry) Huang      07/28/2003
--            changed interface names
--
--            Zhijun (Jerry) Huang      09/08/2003
--            Added parameter legality expressions
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_fir_seq is
  generic(data_in_width : POSITIVE := 8;
          coef_width : POSITIVE := 8;
          data_out_width : POSITIVE := 18;
          order : POSITIVE  := 6);
  port(clk : std_logic;
       rst_n : std_logic;
       coef_shift_en : std_logic;
       tc : std_logic;
       run : std_logic;
       data_in : std_logic_vector(data_in_width-1 downto 0);
       coef_in : std_logic_vector(coef_width-1 downto 0);  
       init_acc_val : std_logic_vector(data_out_width-1 downto 0);         
       start : out std_logic;
       hold : out std_logic;
       data_out : out std_logic_vector(data_out_width-1 downto 0));
end DW_fir_seq;


