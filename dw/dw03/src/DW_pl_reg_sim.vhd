--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2007 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly      May 2, 2007
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 5e80c1f5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Pipeline register with parameter control for width, pipe stages
--		as well as non-retimable input or output register
--
--		Register are individually enabled by separate bits of the
--		enable input bus.
--
--
--              Parameters:     Valid Values
--              ==========      ============
--              width           [ > 0 ]
--              in_reg          [ 0 = no fixed input register
--				  1 = fixed (not retimable) input register ]
--              stages          [ > 0 ]
--              out_reg         [ 0 = no fixed output register
--				  1 = fixed (not retimable) output register ]
--              rst_mode        [ 0 = asynchronous reset,
--                                1 = synchronous reset ]
--		
--		Input Ports:	Size	Description
--		===========	====	===========
--		clk		1 bit	Input Clock
--		rst_n		1 bit	Active Low Reset
--		enable	       EW bits	Active High Enable Bus
--		data_in		width	Data input port
--
--		Output Ports	Size	Description
--		============	====	===========
--		data_out	width	Data output port
--
--	where :  EW = min(1, in_reg + stages + out_reg - 1)
--
-- MODIFIED: 
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

architecture sim of DW_pl_reg is
	

-- pragma translate_off

constant en_msb : integer := maximum(0, in_reg+stages+out_reg-2);
constant word_of_Xs : std_logic_vector(width-1 downto 0) := (others => 'X');

signal clk_int, rst_n_a, rst_n_s : std_logic;
signal enable_int : std_logic_vector(en_msb downto 0);
signal data_in_int : std_logic_vector(width-1 downto 0);
type pipe_T is array (0 to en_msb) of std_logic_vector(width-1 downto 0);
signal pipe_regs : pipe_T;

-- pragma translate_on
begin
-- pragma translate_off

  clk_int <= To_X01(clk);
  rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
  rst_n_s <= To_X01(rst_n);
  enable_int <= To_X01(enable);
  data_in_int <= To_X01(data_in);




  data_out <= data_in_int when ((in_reg+stages+out_reg) = 1) else pipe_regs(en_msb);




  ---------------------------------------------------------------------------
  -- Parameter legality check  
  ---------------------------------------------------------------------------
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if (width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 1)"
        severity warning;
    end if;
  
    if ( (stages < 1) OR (stages > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter stages (legal range: 1 to 1024)"
        severity warning;
    end if;
  
    if ( (in_reg < 0) OR (in_reg > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter in_reg (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (out_reg < 0) OR (out_reg > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter out_reg (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (in_reg/=0) AND (out_reg/=0) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid configuration of DW_pl_reg - 'in_reg' and 'out_reg' parameters can't both be non-zero"
        severity warning;
    end if;
  
    if ( (rst_mode < 0) OR (rst_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  
  monitor_clk  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process monitor_clk ;

-- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_pl_reg_cfg_sim of DW_pl_reg is
 for sim
 end for; -- sim
end DW_pl_reg_cfg_sim;
-- pragma translate_on
