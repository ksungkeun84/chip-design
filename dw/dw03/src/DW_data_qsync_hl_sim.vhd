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
-- AUTHOR:    "Bruce Dean May 25 2006"
--
-- VERSION:   Entity
--
-- DesignWare_version: 7bf3c428
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--
-- ABSTRACT: 
--           - 
--             Parameters:     Valid Values
--             =======      ========
--             width           1 to 1024      8
--             clk_ratio       2 to 1024      2
--             reg_data_s      0 to 1         1
--             reg_data_d      0 to 1         1
--             tst_mode        0 to 2         0
--
--
--             Input Ports:    Size    Description
--             ========     ===    ========
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
--             Output Ports    Size    Description
--             ========    ===    ========
--             data_d          width    Destination domain data output
--             data_avail_d    1        Destination domain data update output
--           - 
-- 
-- MODIFIED:
--
-------------------------------------------------------------------------------
--
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
--
architecture sim of DW_data_qsync_hl is
	
constant reset         : std_logic_vector(4 downto 0) :="00000";
constant idle          : std_logic_vector(4 downto 0) :="00001";
constant update_a      : std_logic_vector(4 downto 0) :="00010";
constant update_b      : std_logic_vector(4 downto 0) :="00100";
constant update_hold   : std_logic_vector(4 downto 0) :="01000";
constant update_send   : std_logic_vector(4 downto 0) :="10000";

signal  data_s_reg     : std_logic_vector (width-1 downto 0); 
signal  data_s_mux     : std_logic_vector (width-1 downto 0); 
signal  send_state     : std_logic_vector (4 downto 0); 
signal  next_state     : std_logic_vector (4 downto 0); 
signal  tmg_ref_cc     : std_logic;
signal  tmg_ref_ccm    : std_logic;
signal  tmg_ref_l      : std_logic;
signal  tmg_ref_data   : std_logic;
signal  tmg_ref_reg    : std_logic;
signal  tmg_ref_mux    : std_logic;
signal  tmg_ref_neg    : std_logic;
signal  tmg_ref_pos    : std_logic;
signal  tmg_ref_xi     : std_logic;
signal  tmg_ref_xo     : std_logic;
signal  tmg_ref_fb     : std_logic;
signal  data_avl_out   : std_logic;
signal  data_avail_r   : std_logic;
signal  data_avail_s   : std_logic;
signal  data_s_snd_en  : std_logic;
signal  data_s_reg_en  : std_logic;
signal  data_s_snd     : std_logic_vector (width-1 downto 0);
signal  send_s_en      : std_logic;
signal  data_m_sel     : std_logic;
signal  tmg_ref_fben   : std_logic;
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
 SRC_DM_SEQ_PROC : process ( clk_s , rst_s_n) begin 
    if  (rst_s_n = '0')  then
      data_s_reg   <= (others => '0');
      data_s_snd   <= (others => '0');
      send_state   <= (others => '0');
      data_avail_r <= '0';
      tmg_ref_xi   <= '0';
      tmg_ref_reg  <= '0';
      tmg_ref_pos  <= '0';
      data_avail_d <= '0';
    elsif  (rst_s_n = '1')  then 
      if(clk_s'event and clk_s='1') then
        if ( init_s_n = '0')  then
          data_s_reg   <= (others => '0');
          data_s_snd   <= (others => '0');
          send_state   <= (others => '0');
          data_avail_r <= '0';
          tmg_ref_xi   <= '0';
          tmg_ref_reg  <= '0';
          tmg_ref_pos  <= '0';
          data_avail_d <= '0';
        elsif ( init_s_n = '1')  then 
	  if(data_s_reg_en = '1')then
            data_s_reg   <= data_s;
	  end if;
          if(data_s_snd_en = '1')then
            data_s_snd   <= data_s_mux;
	  end if;
          send_state   <= next_state;
	  data_avail_r <= data_avl_out;
          tmg_ref_xi   <= tmg_ref_xo;
          tmg_ref_reg  <= tmg_ref_mux;
          tmg_ref_pos  <= tmg_ref_data;
          data_avail_d <= data_avl_out;
        else
          send_state   <= (others => 'X');
          data_s_reg   <= (others => 'X');
          data_s_snd   <= (others => 'X');
          data_avail_r <= 'X';
          tmg_ref_xi   <= 'X';
          tmg_ref_reg  <= 'X';
          tmg_ref_pos  <= 'X';
          data_avail_d <= 'X';
        end if;
      elsif(clk_s'event and clk_s='0') then
        if ( init_s_n = '0')  then
          tmg_ref_neg  <= '0';
        elsif ( init_s_n = '1')  then 
          tmg_ref_neg  <= tmg_ref_data;
        else
          tmg_ref_neg  <= 'X';
        end if;
      elsif(clk_s='0') then
      elsif(clk_s='1') then
      else
        send_state   <= (others => 'X');
        data_s_reg   <= (others => 'X');
        data_s_snd   <= (others => 'X');
	data_avail_r <= 'X';
        tmg_ref_xi   <= 'X';
        tmg_ref_reg  <= 'X';
        tmg_ref_pos  <= 'X';
        tmg_ref_neg  <= 'X';
        data_avail_d <= 'X';
      end if;
    else
      send_state   <= (others => 'X');
      data_s_reg   <= (others => 'X');
      data_s_snd   <= (others => 'X');
      data_avail_r <= 'X';
      tmg_ref_xi   <= 'X';
      tmg_ref_reg  <= 'X';
      tmg_ref_pos  <= 'X';
      tmg_ref_neg  <= 'X';
      data_avail_d <= 'X';
    end if; 
  end  process;

  DST_DM_P_SEQ_PROC : process ( clk_d , rst_d_n) begin --: DST_DM_POS_SEQ_PROC
    if (rst_d_n = '0' ) then
      tmg_ref_data <= '0';
    elsif (rst_d_n = '1' ) then 
      if(clk_d = '0') then
      elsif(clk_d = '1') then
        if (init_d_n = '0' ) then
          tmg_ref_data <= '0';
        elsif (init_d_n = '1' ) then
	  if(data_avail_r = '1') then 
            tmg_ref_data <= not tmg_ref_data;-- and data_avail_r;
	  end if;
	else
          tmg_ref_data <= 'X';
        end if;
      else
        tmg_ref_data <= 'X';
      end if;
    else
      tmg_ref_data <= 'X';
    end if; 
  end  process;
  
  SRC_DM_COMB_PROC : process (send_state, send_s, tmg_ref_fb, clk_s ) begin
    case (send_state) is
      when  reset => 
	next_state <=  idle;
      when  idle => 
        if send_s = '1' then
	  next_state <=  update_a;
        else
	  next_state <=  idle;
        end if;
      when   update_a => 
        if(send_s = '1') then
	  next_state <=  update_b;
        else
	  next_state <=  update_hold;
        end if;
      when  update_b => 
        if(tmg_ref_fb = '1' and send_s = '0') then
	  next_state <=  update_hold;
        else
	  next_state <=  update_b;
        end if;
      when   update_hold => 
        if(send_s = '1' and tmg_ref_fb = '0') then
	  next_state <=  update_b;
        elsif(send_s = '1' and tmg_ref_fb = '1') then
	  next_state <=  update_hold;
        elsif(send_s = '0' and tmg_ref_fb = '1') then
	  next_state <=  idle;
        else
	  next_state <=  update_hold;
        end if;
      when others => next_state <= reset;
    end case;
  end process;
  SRC_DM_LATCH : process (clk_s, tmg_ref_cc) begin 
    if (clk_s = '1') then
      tmg_ref_l <= tmg_ref_cc;
    end if;
  end process;
  data_avl_out   <= next_state(1) or next_state(2) or next_state(3);
  tmg_ref_xo     <= tmg_ref_reg xor tmg_ref_mux;
  tmg_ref_fb     <= tmg_ref_xo;--not (tmg_ref_xi or tmg_ref_xo) when clk_ratio <= 3 else tmg_ref_xo;
  tmg_ref_mux    <= tmg_ref_neg when clk_ratio = 2 else tmg_ref_pos ;
  tmg_ref_fben   <= next_state(1) or next_state(2) or next_state(3);
  data_s_mux     <= data_s when (data_m_sel = '1') else data_s_reg;
  data_m_sel     <= (send_state(0) or (send_state(3) and data_s_snd_en)) ;
  data_s_reg_en  <= (send_state(2) or (send_state(3) and not tmg_ref_fb)) and send_s;
  data_s_snd_en  <= (send_state(0) and send_s)  or (send_state(2) and tmg_ref_fb) or
                    (send_state(3) and tmg_ref_fb and send_s);
  data_d         <= data_s_snd;
  tmg_ref_ccm    <= tmg_ref_l when ((clk_ratio > 2) and (test = '1')) else tmg_ref_cc;
  -- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_data_qsync_hl_cfg_sim of DW_data_qsync_hl is
 for sim
 end for; -- sim
end DW_data_qsync_hl_cfg_sim;
-- pragma translate_on
