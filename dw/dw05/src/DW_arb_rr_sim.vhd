--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean       Jul 10, 2006 
--
-- VERSION:   VHDL Simulation Architecture
--
-- DesignWare_version: 2eefc1e0
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Arbiter with Round-Robin priority scheme
-- 
-- MODIFIED:
--
--    RJK - 06/19/15
--    Added missing signal to next state process sensitivity list
--    (STAR 9000913972)
--
--    RJK - 12/12/12
--    Updated to properly model combinational output flow when the
--    output_mode parameter is set to 0 (STAR 9000589357)
--
--    RJK - 10/01/12
--    Enhancement that adds a new parameter to control the operation
--    of the grant_index output.
--
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
architecture sim of DW_arb_rr is
	
  constant indx_offset:INTEGER  := 1 - (index_mode/2);
  constant indx_width : INTEGER := bit_width(n + (index_mode mod 2));
  signal   req_ro     : std_logic := '0'; 
  signal   grant_ro   : std_logic := '0'; 
  signal   grant_cs   : std_logic_vector(n-1 downto 0);
  signal   grant_ns   : std_logic_vector(n-1 downto 0);
  signal   grant_sh   : std_logic_vector(n-1 downto 0);
  signal   masked_req : std_logic_vector(n-1 downto 0);
  signal   granted_r  : std_logic;
  signal   grant_indxr : std_logic_vector(indx_width-1 downto 0); -- count memory
  signal   grant_indxn : std_logic_vector(indx_width-1 downto 0); -- count memory
  signal   token_cs : integer := 0; --current token owner
  signal   token_ns : integer := 0; --next token owner
  signal   count   : integer := 0; -- count of masked_reqors
  signal   maxindx : integer := n-1; -- count of index values
  signal   inloop     : std_logic_vector ((n*n)-1 downto 0):= (others => '0'); 
  signal   inloop1     : std_logic_vector (n-1 downto 0):= (others => '0'); 
begin
  -----------------------------------------------------------------------------
  -- Behavioral model
  -- pragma translate_off
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- Parameter legality check
  -----------------------------------------------------------------------------
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (n < 2) OR (n > 256) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter n (legal range: 2 to 256)"
        severity warning;
    end if;
    
    if ( (output_mode < 0) OR (output_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter output_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (index_mode < 0) OR (index_mode > 2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter index_mode (legal range: 0 to 2)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
  -----------------------------------------------------------------------------
  -- Report unknown clock inputs
  -----------------------------------------------------------------------------
  
  clk_monitor : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process clk_monitor;
  masked_req <= request and not mask;
  REQ_COMBO: process (masked_req) 
    variable z : std_logic := '0';
    begin      
      z   := '0';
      for i in 0 to n-1 loop 
        z   := masked_req(i) or z;
      end loop;
      req_ro <= z;  
  end process;
  MK_NXT_STATE: process (enable, token_cs, masked_req, req_ro, granted_r)
  variable   index    : integer := 0;
  variable count : integer ;
  begin
  grant_ro           <= '0';
    if(enable = '1') then
      if(masked_req(token_cs) = '1')then
        grant_ns           <= (others => '0');
        grant_ns(token_cs) <= '1';
        token_ns           <= token_cs;
        grant_indxn        <= CONV_STD_LOGIC_VECTOR(token_cs+indx_offset,indx_width);
	grant_ro           <= '1';
      elsif(req_ro = '1') then
      inloop <= (others => '0');
        count := 0;
        loop
	  index           := (count + token_cs)mod n;
          if(masked_req(index) = '1' )then
            grant_ns        <= (others => '0');
            grant_ns(index) <= '1';
            token_ns        <= index;
            grant_indxn     <= CONV_STD_LOGIC_VECTOR(index+indx_offset,indx_width);
	    grant_ro        <= '1';
	    exit when true;
          end  if;
	  exit when count = n-1;
	  count := count + 1;
        end loop;
      elsif(req_ro = '0' and granted_r = '1')then  
        if (token_cs = n-1) then
          token_ns <= 0; 
        else
          token_ns <= token_cs + 1;
	end if;
        grant_ns    <= (others => '0');
        grant_indxn <= (others => '0');
	grant_ro    <= '0';
      elsif(req_ro = '0'  and granted_r = '0') then
        token_ns    <= token_cs; 
        grant_ns    <= (others => '0');
        grant_indxn <= (others => '0');
	grant_ro    <= '0';
      end if;
    elsif(enable = '0') then
      grant_ns    <= (others => '0');
      token_ns    <= 0;
      grant_indxn <= (others => '0');
    else
      grant_ns    <= (others => 'X');
      token_ns    <= 0;
      grant_indxn <= (others => 'X');
      grant_ro    <= 'X';
    end if;
  end process;
  GRANT_REGISTER: process (clk, rst_n) 
    begin
    if(rst_n = '0') then
      token_cs    <= 0;
      grant_cs    <= (others => '0');
      grant_indxr <= (others => '0');
      granted_r   <= '0';
    elsif(rst_n = '1') then
      if(rising_edge(clk)) then
        if (init_n = '0') then
          token_cs  <= 0;
          grant_cs  <= (others => '0');
          grant_indxr  <= (others => '0');
          granted_r <= '0';
        elsif (init_n = '1') then
          token_cs    <= token_ns;
          grant_cs    <= grant_ns;
          grant_indxr <= grant_indxn;
          granted_r   <= grant_ro;
        else  
          token_cs     <= 0;
          grant_cs     <= (others => 'X');
          grant_indxr  <= (others => 'X');
          granted_r    <= 'X';
        end if;
      end if;
    else 
      token_cs  <= 0;
      grant_cs  <= (others => 'X');
      grant_indxr  <= (others => 'X');
      granted_r <= 'X';
    end if;
  end process;
  granted     <= granted_r when (output_mode = 1) else grant_ro;
  grant       <= grant_cs  when (output_mode = 1) else grant_ns;
  grant_index <= grant_indxr when (output_mode = 1) else grant_indxn;
  -- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_arb_rr_cfg_sim of DW_arb_rr is
 for sim
 end for; -- sim
end DW_arb_rr_cfg_sim;
-- pragma translate_on
