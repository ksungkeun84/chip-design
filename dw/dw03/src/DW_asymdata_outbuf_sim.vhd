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
-- AUTHOR:    Doug Lee  May 26, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: f4665817
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Asymmetric Data Transfer Output Buffer Entity
--
--           Output multiplexer used for asymmetric data transfers when the
--           input data width is greater than and an integer multiple
--           of the output data width.
--
--              Parameters:     Valid Values
--              ==========      ============
--              in_width        [ 1 to 2048]
--              out_width       [ 1 to 2048]
--                  Note: in_width must be greater than
--                        out_width and an integer multiple:
--                        that is, in_width = K * out_width
--              err_mode        [ 0 = sticky error flag,
--                                1 = dynamic error flag ]
--              byte_order      [ 0 = the first byte (or subword) is in MSBs
--                                1 = the first byte (or subword) is in LSBs ]
--
--              Input Ports     Size    Description
--              ===========     ====    ===========
--              clk_pop         1 bit   Pop I/F Input Clock
--              rst_pop_n       1 bit   Async. Pop Reset (active low)
--              init_pop_n      1 bit   Sync. Pop Reset (active low)
--              pop_req_n       1 bit   Active Low Pop Request
--              data_in         M bits  Data full word being popped
--              fifo_empty      1 bit   Empty indicator from fifoctl that RAM/FIFO is empty
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              pop_wd_n        1 bit   Full word read (active low)
--              data_out        N bits  Data subword into RAM or FIFO
--              part_wd         1 bit   Partial word poped flag
--              pop_error       1 bit   Underrun of RAM or FIFO
--
--                Note: M is the value of the parameter in_width
--                      N is the value of the parameter out_width
--
--
-- MODIFIED:
--
--  
--	RJK 03/29/18    Updated max in_width and out_width as appropriate
--	                (STAR 9001317257)
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;

architecture sim of DW_asymdata_outbuf is
	
  constant K : INTEGER := in_width/out_width;
  constant CNT_WIDTH : INTEGER := bit_width(K);

  signal pop_req_n_int           : std_logic;
  signal data_in_int             : std_logic_vector(in_width-1 downto 0);
  signal fifo_empty_int          : std_logic;
  signal part_wd_int             : std_logic; 
  signal pop_wd_n_int            : std_logic;
  signal pop_error_int           : std_logic;
  signal next_pop_error_int      : std_logic;
  signal pre_next_pop_error_int  : std_logic;
  signal data_out_int            : std_logic_vector(out_width-1 downto 0);

  signal cntr                    : std_logic_vector(CNT_WIDTH-1 downto 0);
  signal next_cntr               : std_logic_vector(CNT_WIDTH-1 downto 0);

begin
-- pragma translate_off

  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if ( (in_width < 1) OR (in_width > 2048) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter in_width (legal range: 1 to 2048)"
        severity warning;
    end if;
  
    if ( (out_width < 1) OR (out_width > 2048) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter out_width (legal range: 1 to 2048)"
        severity warning;
    end if;
  
    if ( (err_mode < 0) OR (err_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter err_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (byte_order < 0) OR (byte_order > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter byte_order (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  pop_req_n_int      <= To_X01(pop_req_n);
  data_in_int        <= To_X01(data_in);
  fifo_empty_int     <= To_X01(fifo_empty);

------------------------------------------------------------------------
pop_wd_n_proc : process (pop_req_n_int, cntr, pre_next_pop_error_int)
  begin
    if ((pop_req_n_int = '0') AND (pre_next_pop_error_int = '0') AND
	 (cntr = CONV_STD_LOGIC_VECTOR(K-1, CNT_WIDTH))) then
      pop_wd_n_int <= '0';
    else
      if (pop_req_n_int = 'X') then
        pop_wd_n_int <= 'X';
      else
        pop_wd_n_int <= '1';
      end if;
    end if;
  end process pop_wd_n_proc;
------------------------------------------------------------------------

------------------------------------------------------------------------
-- part_wd_int         <= '1' when (cntr > CONV_STD_LOGIC_VECTOR(0, CNT_WIDTH)) else '0';
part_wd_proc : process (cntr)
  begin
    if (cntr > CONV_STD_LOGIC_VECTOR(0, CNT_WIDTH)) then
      part_wd_int  <= '1';
    else
      if (cntr = CONV_STD_LOGIC_VECTOR(0, CNT_WIDTH)) then
        part_wd_int  <= '0';
      else
        part_wd_int  <= 'X';
      end if;
    end if;
  end process part_wd_proc;
------------------------------------------------------------------------


------------------------------------------------------------------------

  pre_next_pop_error_int <= '1' when ((pop_req_n_int = '0') AND (fifo_empty_int = '1')) else '0';

  next_pop_error_int <= (pre_next_pop_error_int OR pop_error_int) when (err_mode = 0) else
			  pre_next_pop_error_int;

------------------------------------------------------------------------
next_cntr_proc : process (pop_req_n_int, cntr, pre_next_pop_error_int, fifo_empty_int)
  begin
    if ((pop_req_n_int = 'X') OR ((pop_req_n_int = '0') AND (fifo_empty_int = 'X'))) then
      next_cntr <= (others => 'X');
    elsif ((pop_req_n_int = '0') AND (pre_next_pop_error_int = '0')) then
      if (cntr = CONV_STD_LOGIC_VECTOR(K-1, CNT_WIDTH)) then
        next_cntr <= CONV_STD_LOGIC_VECTOR(0, CNT_WIDTH);
      else
        next_cntr <=  CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(cntr))+1), CNT_WIDTH);
      end if;
    else
      next_cntr <= cntr;
    end if;
  end process next_cntr_proc;



------------------------------------------------------------------------

data_out_proc : process(data_in_int, cntr)
  variable w_sw : integer := 0;
  variable w_b : integer := 0;
  begin
    data_out_int <= (others => '0');
    if (byte_order = 0) then
      for w_sw in 0 to (K-1) loop
	for w_b in 0 to (out_width-1) loop
          if (w_sw = CONV_INTEGER(UNSIGNED(cntr))) then
  	    data_out_int(w_b) <= data_in_int((in_width-(out_width*(w_sw+1)))+w_b);
          end if;
        end loop;  -- w_b
      end loop;  -- w_sw
    else
      for w_sw in 0 to (K-1) loop
	for w_b in 0 to (out_width-1) loop
          if (w_sw = CONV_INTEGER(UNSIGNED(cntr))) then
	    data_out_int(w_b) <= data_in_int((out_width*w_sw)+w_b);
          end if;
        end loop;  -- w_b
      end loop;  -- w_sw
    end if;
  end process data_out_proc;

------------------------------------------------------------------------

sim_clk_pop: process (clk_pop, rst_pop_n)
  variable i : integer := 0;
  begin
    if (rst_pop_n = '0') then
      cntr           <= (others => '0');
      pop_error_int  <= '0';
    elsif (rst_pop_n = '1') then
      if (rising_edge(clk_pop)) then
        if (init_pop_n = '0') then
          cntr            <= (others => '0');
          pop_error_int  <= '0';
        elsif (init_pop_n = '1') then
          cntr           <= next_cntr;
          pop_error_int  <= next_pop_error_int;
        else
          cntr           <= (others => 'X');
          pop_error_int  <= 'X';
        end if;
      else
        cntr           <= cntr;
        pop_error_int  <= pop_error_int;
      end if;
    else
      cntr           <= (others => 'X');
      pop_error_int  <= 'X';
    end if;
  end process sim_clk_pop;


  pop_wd_n     <= pop_wd_n_int;
  data_out     <= data_out_int;
  part_wd      <= part_wd_int;
  pop_error    <= pop_error_int;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_asymdata_outbuf_cfg_sim of DW_asymdata_outbuf is
 for sim
 end for; -- sim
end DW_asymdata_outbuf_cfg_sim;
-- pragma translate_on
