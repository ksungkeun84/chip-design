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
-- AUTHOR:    Doug Lee  May 11, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: e710dd1d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Asymmetric Data Input Buffer Simulation Model
--
--           Input registers used for asymmetric data transfer when the
--           input data width is less than and an integer multiple
--           of the output data width.
--
--              Parameters:     Valid Values
--              ==========      ============
--              in_width        [ 1 to 2048]
--              out_width       [ 1 to 2048]
--                  Note: in_width must be less than
--                        out_width and an integer multiple:
--                        that is, out_width = K * in_width
--              err_mode        [ 0 = sticky error flag,
--                                1 = dynamic error flag ]
--              byte_order      [ 0 = the first byte (or subword) is in MSBs
--                                1 = the first byte  (or subword)is in LSBs ]
--              flush_value     [ 0 = fill empty bits of partial word with 0's upon flush
--                                1 = fill empty bits of partial word with 1's upon flush ]
--
--              Input Ports     Size    Description
--              ===========     ====    ===========
--              clk_push        1 bit   Push I/F Input Clock
--              rst_push_n      1 bit   Async. Push Reset (active low)
--              init_push_n     1 bit   Sync. Push Reset (active low)
--              push_req_n      1 bit   Push Request (active low)
--              data_in         M bits  Data subword being pushed
--              flush_n         1 bit   Flush the partial word into
--                                      the full word memory (active low)
--              fifo_full       1 bit   Full indicator of RAM/FIFO
--
--              Output Ports    Size    Description
--              ============    ====    ===========
--              push_wd_n       1 bit   Full word ready for transfer (active low)
--              data_out        N bits  Data word into RAM or FIFO
--              inbuf_full      1 bit   Inbuf registers all contain active data_in subwords
--              part_wd         1 bit   Partial word pushed flag
--              push_error      1 bit   Overrun of RAM or FIFO (includes inbuf registers)
--
--                Note: M is the value of the parameter in_width
--                      N is the value of the parameter out_width
--
--
-- MODIFIED:
--  
--  03/29/18  RJK   Updated max in_width and out_width as appropriate
--	            STAR 9001317257)
--
--   10/27/09  DLL  Addresses STAR#9000351964.  Fixed data corruption in
--                  the case when both flush and push are requested
--                  with the input buffer empty.
--
------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;

architecture sim of DW_asymdata_inbuf is
	
  constant K : INTEGER := out_width/in_width;
  constant CNT_WIDTH : INTEGER := bit_width(K);
  type reg_array is array (0 to K-2) of 
       std_logic_vector(in_width-1 downto 0);
  signal data_reg                 : reg_array;
  signal next_data_reg            : reg_array;
  signal push_req_n_int           : std_logic;
  signal data_in_int              : std_logic_vector(in_width-1 downto 0);
  signal fifo_full_int            : std_logic;
  signal flush_n_int              : std_logic;
  signal part_wd_int              : std_logic; 
  signal push_wd_n_int            : std_logic;
  signal push_error_int           : std_logic;
  signal next_push_error_int      : std_logic;
  signal pre_next_push_error_int  : std_logic;
  signal data_out_int             : std_logic_vector(out_width-1 downto 0);
  signal inbuf_full_int           : std_logic;

  signal cntr                     : std_logic_vector(CNT_WIDTH-1 downto 0);
  signal next_cntr                : std_logic_vector(CNT_WIDTH-1 downto 0);

  signal flush_ok                 : std_logic;

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
  
    if ( (flush_value < 0) OR (flush_value > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter flush_value (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;


  push_req_n_int      <= To_X01(push_req_n);
  flush_n_int         <= To_X01(flush_n);
  data_in_int         <= To_X01(data_in);
  fifo_full_int       <= To_X01(fifo_full);

------------------------------------------------------------------------
push_wd_n_proc : process (push_req_n_int, inbuf_full_int, flush_ok,
                          pre_next_push_error_int)
  begin
    if ((((push_req_n_int = '0') AND (inbuf_full_int = '1')) OR
        (flush_ok = '1')) AND (pre_next_push_error_int = '0')) then
      push_wd_n_int <= '0';
    else
      if ((push_req_n_int = 'X') OR (flush_ok = 'X')) then
        push_wd_n_int <= 'X';
      else
        push_wd_n_int <= '1';
      end if;
    end if;
  end process push_wd_n_proc;
------------------------------------------------------------------------

------------------------------------------------------------------------
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
inbuf_full_proc : process (cntr)
  begin
    if (cntr > CONV_STD_LOGIC_VECTOR(K-2, CNT_WIDTH)) then
      inbuf_full_int  <= '1';
    else
      if (cntr <= CONV_STD_LOGIC_VECTOR(K-2, CNT_WIDTH)) then
        inbuf_full_int  <= '0';
      else
        inbuf_full_int  <= 'X';
      end if;
    end if;
  end process inbuf_full_proc;
------------------------------------------------------------------------


------------------------------------------------------------------------
flush_ok_process : process (flush_n_int, part_wd_int, fifo_full_int)
  begin
    if ((flush_n_int = '0') AND (part_wd_int = '1') AND (fifo_full_int = '0')) then
      flush_ok <= '1';
    else
      if (((flush_n_int = 'X') AND (part_wd_int = '1') AND (fifo_full_int = '0')) OR
           ((fifo_full_int = 'X') AND (part_wd_int = '1'))) then
        flush_ok <= 'X';
      else
        flush_ok <= '0';
      end if; 
    end if;
  end process flush_ok_process;
------------------------------------------------------------------------

------------------------------------------------------------------------
pre_next_push_error_proc : process (push_req_n_int, flush_n_int, part_wd_int, inbuf_full_int, fifo_full_int)
  begin
    if (((flush_n_int = '0') AND (part_wd_int = '1')) OR
        ((push_req_n_int = '0') AND (inbuf_full_int = '1'))) AND
        (fifo_full_int = '1') then
      pre_next_push_error_int <= '1';
    else
      if ((push_req_n_int = 'X') OR ((flush_n_int = 'X') AND (part_wd_int = '1') AND
          (fifo_full_int = '0')) OR
          ((fifo_full_int = 'X') AND (((push_req_n_int = '0') AND (inbuf_full_int = '1')) OR
             ((flush_n_int = '0') AND (part_wd_int = '1'))))) then
        pre_next_push_error_int <= 'X';
      else
        pre_next_push_error_int <= '0';
      end if;
    end if;
  end process pre_next_push_error_proc;

  next_push_error_int <= (pre_next_push_error_int OR push_error_int) when (err_mode = 0) else
			    pre_next_push_error_int;

------------------------------------------------------------------------
next_cntr_proc : process (push_req_n_int, flush_ok, cntr, inbuf_full_int,
                          pre_next_push_error_int, fifo_full_int)
  begin
    if ((push_req_n_int = 'X') OR (flush_ok = 'X') OR
        ((push_req_n_int = '0') AND (inbuf_full_int = '1') AND (fifo_full_int = 'X'))) then
      next_cntr <= (others => 'X');
    elsif ((push_req_n_int = '0') AND (flush_ok = '1')) then
      next_cntr <= CONV_STD_LOGIC_VECTOR(1, CNT_WIDTH);
    else
      if (flush_ok = '1') then
        next_cntr <= CONV_STD_LOGIC_VECTOR(0, CNT_WIDTH);
      else
        if ((push_req_n_int = '0') AND (pre_next_push_error_int = '0')) then
          if (cntr = CONV_STD_LOGIC_VECTOR(K-1, CNT_WIDTH)) then
            next_cntr <= CONV_STD_LOGIC_VECTOR(0, CNT_WIDTH);
          else
            next_cntr <=  CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(cntr))+1), CNT_WIDTH);
          end if;
        else
          if ((push_req_n_int = '0') AND (inbuf_full_int = '0')) then
            next_cntr <=  CONV_STD_LOGIC_VECTOR((CONV_INTEGER(UNSIGNED(cntr))+1), CNT_WIDTH);
          else
            next_cntr <= cntr;
          end if;
        end if;
      end if;
    end if;
  end process next_cntr_proc;


------------------------------------------------------------------------
next_data_reg_proc : process (push_req_n_int, flush_ok, data_in_int, cntr, data_reg)
  variable i : integer := 0;
  begin
    if (push_req_n_int = '0') then
      if (flush_ok = '0') then
        for i in 0 to K-2 loop
          if (CONV_STD_LOGIC_VECTOR(i, CNT_WIDTH) = cntr) then
            next_data_reg(i) <= data_in_int;
          elsif (CONV_STD_LOGIC_VECTOR(i, CNT_WIDTH) < cntr) then
            next_data_reg(i) <= data_reg(i);
          else
            if (flush_value = 0) then
              next_data_reg(i) <= CONV_STD_LOGIC_VECTOR(0, in_width);
            else
              next_data_reg(i) <= CONV_STD_LOGIC_VECTOR(-1, in_width);
            end if;
          end if;
        end loop;
      else
        next_data_reg(0) <= data_in_int;
        for i in 1 to K-2 loop
          if (flush_value = 0) then
            next_data_reg(i) <= CONV_STD_LOGIC_VECTOR(0, in_width);
          else
            next_data_reg(i) <= CONV_STD_LOGIC_VECTOR(-1, in_width);
          end if;
        end loop;
      end if;
    else
      for i in 0 to K-2 loop
        next_data_reg(i) <= data_reg(i);
      end loop;
    end if;
  end process next_data_reg_proc;



------------------------------------------------------------------------

data_out_proc : process(data_in_int, data_out_int, flush_ok, cntr, data_reg )
  variable w_sw : integer := 0;
  variable w_b : integer := 0;
  begin
    if (byte_order = 0) then
      for w_sw in 0 to (K-1) loop
        if (flush_ok = '1') then
          if (w_sw = K-1) then
            if (flush_value = 0) then
              data_out_int(in_width-1 downto 0) <= (others => '0');
            else
              data_out_int(in_width-1 downto 0) <=  CONV_STD_LOGIC_VECTOR(-1, in_width);
            end if;
          else
            data_out_int(out_width-(in_width*w_sw)-1 downto
                         out_width-(in_width*(w_sw+1))) <= data_reg(w_sw);
          end if;
        else
          if (w_sw = K-1) then
            data_out_int(in_width-1 downto 0) <= data_in_int;
          else
            data_out_int(out_width-(in_width*w_sw)-1 downto
                         out_width-(in_width*(w_sw+1))) <= data_reg(w_sw);
          end if;
        end if;
      end loop;
    else
      for w_sw in 0 to (K-1) loop
        if (flush_ok = '1') then
          if (w_sw = K-1) then
            if (flush_value = 0) then
              data_out_int(out_width-1 downto 
                           out_width-in_width) <= (others => '0');
            else
              data_out_int(out_width-1 downto 
                           out_width-in_width) <=  CONV_STD_LOGIC_VECTOR(-1, in_width);
            end if;
          else
            data_out_int(in_width*(w_sw+1)-1 downto
                         in_width*w_sw) <= data_reg(w_sw);
          end if;
        else
          if (w_sw = K-1) then
            data_out_int(out_width-1 downto 
                         out_width-in_width) <= data_in_int;
          else
            data_out_int(in_width*(w_sw+1)-1 downto
                         in_width*w_sw) <= data_reg(w_sw);
          end if;
        end if;
      end loop;
    end if;
  end process data_out_proc;

------------------------------------------------------------------------

sim_clk_push: process (clk_push, rst_push_n)
  variable i : integer := 0;
  begin
    if (rst_push_n = '0') then
      for i in 0 to K-2 loop
        data_reg(i)     <= (others => '0');
      end loop;
      cntr            <= (others => '0');
      push_error_int  <= '0';
    elsif (rst_push_n = '1') then
      if (rising_edge(clk_push)) then
        if (init_push_n = '0') then
          for i in 0 to K-2 loop
            data_reg(i)     <= (others => '0');
          end loop;
          cntr            <= (others => '0');
          push_error_int  <= '0';
        elsif (init_push_n = '1') then
          for i in 0 to K-2 loop
            data_reg(i)     <= next_data_reg(i);
          end loop;
          cntr            <= next_cntr;
          push_error_int  <= next_push_error_int;
        else
          for i in 0 to K-2 loop
            data_reg(i)     <= (others => 'X');
          end loop;
          cntr            <= (others => 'X');
          push_error_int  <= 'X';
        end if;
      else
        for i in 0 to K-2 loop
          data_reg(i)     <= data_reg(i);
        end loop;
        cntr            <= cntr;
        push_error_int  <= push_error_int;
      end if;
    else
      for i in 0 to K-2 loop
        data_reg(i)     <= (others => 'X');
      end loop;
      cntr            <= (others => 'X');
      push_error_int  <= 'X';
    end if;
  end process sim_clk_push;


  push_wd_n     <= push_wd_n_int;
  data_out      <= data_out_int;
  part_wd       <= part_wd_int;
  inbuf_full    <= inbuf_full_int;
  push_error    <= push_error_int;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_asymdata_inbuf_cfg_sim of DW_asymdata_inbuf is
 for sim
 end for; -- sim
end DW_asymdata_inbuf_cfg_sim;
-- pragma translate_on
