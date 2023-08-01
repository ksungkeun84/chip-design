----------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2004 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    "Bruce Dean May 18 2006"
--
-- VERSION:   Entity
--
-- DesignWare_version: 01802b89
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
-- ABSTRACT: 
--           - 
--             Parameters:     Valid Values   Default Values
--             ==========      ============   ==============
--             width           1 to 1024      8
--             clk_ratio       2 to 1024      2
--             reg_data_s      0 to 1         1
--             reg_data_d      0 to 1         1
--             tst_mode        0 to 2         0
--
--             Input Ports:    Size    Description
--             ===========     ====    ===========
--             clk_s            1        Source clock
--             rst_s_n          1        Source domain asynch. reset (active low)
--             init_s_n         1        Source domain synch. reset (active low)
--             send_s           1        Source domain send request input
--             data_s           width    Source domain send data input
--             clk_d            1        Destination clock
--             rst_d_n          1        Destination domain asynch. reset (active low)
--             init_d_n         1        Destination domain synch. reset (active low)
--             test             1        Scan test mode select input
--
--
--             Output Ports    Size    Description
--             ============    =====    ===========
--             data_d          width    Destination domain data output
--             data_avail_d    1        Destination domain data update output
--           - 
-- 
-- MODIFIED:
--
--  4/5/14  RJK  Corrected behavior with use of reg_data_s and reg_data_d parameters
--               (STAR 9000736629)
--
-------------------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
--
architecture sim of DW_data_qsync_lh is
	
signal  send_s_x        : std_logic;
signal  data_d_mux      : std_logic;
signal  data_d_xvail    : std_logic;
  
signal  data_s_reg      : std_logic_vector (width-1 downto 0); 
signal  send_reg        : std_logic;
signal  data_avail_nreg : std_logic;
signal  data_d_reg      : std_logic_vector (width-1 downto 0);
signal  data_avail_preg : std_logic;
signal  data_avail_xreg : std_logic;
signal  data_avl_d      : std_logic;
signal  data_s_snd      : std_logic_vector (width-1 downto 0);
signal  send_reg_l      : std_logic;
signal  send_reg_cc     : std_logic;
begin
  -- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (width < 1) OR (width > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter width (legal range: 1 to 1024)"
        severity warning;
    end if;
    
    if ( (clk_ratio < 2) OR (clk_ratio > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter clk_ratio (legal range: 2 to 1024)"
        severity warning;
    end if;
    
    if ( (reg_data_s < 0) OR (reg_data_s > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_data_s (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (reg_data_d < 0) OR (reg_data_d > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter reg_data_d (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (tst_mode < 0) OR (tst_mode > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tst_mode (legal range: 0 to 2)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
  send_s_x <= send_s xor send_reg;

  frwd_hold_latch_PROC : process(clk_s, send_reg) begin
    if (clk_s = '1') then
      send_reg_l <= send_reg;
    end if;
  end process frwd_hold_latch_PROC;

  send_reg_cc <= send_reg_l when ((tst_mode = 2) AND (test = '1')) else send_reg;

  SRC_DM_SEQ_PROC : process ( clk_s , rst_s_n) begin 
    if  (rst_s_n = '0')  then
      data_s_reg <= (others => '0');
      send_reg   <= '0';
    elsif  (rst_s_n = '1')  then 
      if(clk_s'event and clk_s='1') then
        if ( init_s_n = '0')  then
          data_s_reg <= (others => '0');
          send_reg   <= '0';
        elsif ( init_s_n = '1')  then 
	  if (send_s = '1') then
	    data_s_reg <= data_s;
	  end if;
	  send_reg   <= send_s_x;
        else
          data_s_reg <= (others => 'X');
          send_reg   <= 'X';
        end if;
      elsif(clk_s'event and clk_s='0') then
        data_s_reg <= data_s_reg;
        send_reg   <= send_reg;
      elsif(clk_s='0') then
      elsif(clk_s='1') then
      else
        data_s_reg <= (others => 'X');
        send_reg   <= 'X';
      end if;
    else
      data_s_reg <= (others => 'X');
      send_reg   <= 'X';
    end if; 
  end  process;

  DST_DM_P_SEQ_PROC : process ( clk_d , rst_d_n) begin --: DST_DM_POS_SEQ_PROC
    if (rst_d_n = '0' ) then
      data_d_reg      <= (others => '0');
      data_avail_preg <= '0';
      data_avail_nreg <= '0';
      data_avail_xreg <= '0';
      data_avl_d      <= '0';
    elsif (rst_d_n = '1' ) then 
      if(clk_d = '0') then
        if (init_d_n = '0' ) then
          data_avail_nreg <= '0';
        elsif (init_d_n = '1' ) then 
          data_avail_nreg <= send_reg_cc;
	else
	  data_avail_nreg <= 'X';
        end if;
      elsif(clk_d = '1') then
        data_avail_nreg <= data_avail_nreg;
        if (init_d_n = '0' ) then
          data_d_reg      <= (others => '0');
          data_avail_preg <= '0';
          data_avail_xreg <= '0';
          data_avl_d      <= '0';
        elsif (init_d_n = '1' ) then
	  if (data_d_xvail = '1') then
	    data_d_reg      <= data_s_snd;
	  end if;
          data_avail_preg <= send_reg_cc;
          data_avail_xreg <= data_d_mux;
          data_avl_d      <= data_d_xvail;
	else
          data_d_reg      <= (others => 'X');
          data_avail_preg <= 'X';
          data_avail_xreg <= 'X';
          data_avl_d      <= 'X';
        end if;
      --elsif(clk_d = '1') then
      --elsif(clk_d = '0') then
      else
	data_d_reg      <= (others => 'X');
        data_avail_preg <= 'X';
        data_avail_xreg <= 'X';
        data_avl_d      <= 'X';
        data_avail_nreg <= 'X';
      end if;
    else
      data_d_reg      <= (others => 'X');
      data_avail_preg <= 'X';
      data_avail_xreg <= 'X';
      data_avl_d      <= 'X';
      data_avail_nreg <= 'X';    
    end if; 
  end  process;

  data_d_mux   <= data_avail_nreg when ((clk_ratio = 2 ) or ((tst_mode = 1) and (test = '1')))
			else data_avail_preg ;
  data_d       <= data_d_reg when reg_data_d = 1 else data_s_snd;
  data_avail_d <= data_avl_d when reg_data_d = 1 else data_d_xvail;
  data_s_snd   <= data_s_reg when reg_data_s = 1 else data_s;

  data_d_xvail <= data_d_mux xor data_avail_xreg;

  -- pragma translate_on
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_data_qsync_lh_cfg_sim of DW_data_qsync_lh is
 for sim
 end for; -- sim
end DW_data_qsync_lh_cfg_sim;
-- pragma translate_on
