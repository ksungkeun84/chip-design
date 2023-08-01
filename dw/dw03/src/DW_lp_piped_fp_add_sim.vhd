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
-- AUTHOR:    Doug Lee April 2009
--
-- VERSION:   Entity
--
-- DesignWare_version: cbbfa4bc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Low Power Pipelined Divider Simulation Model
--
--           This receives two operands that get addided.  Configurable
--           to provide pipeline registers for both static and re-timing placement.
--           Also, contains pipeline management to optimized for low power.
--
--
--  Parameters:     Valid Values    Description
--  ==========      ============    =============
--   sig_width         >= 1         default: 8
--                                  Width of 'a' operand
--
--   exp_width         >= 1         default: 8
--                                  Width of 'a' operand
--
--   ieee_compliance   0 to 1       support the IEEE Compliance 
--                                  0 - IEEE 754 compatible without denormal support
--                                  (NaN becomes Infinity, Denormal becomes Zero)
--                                  1 - IEEE 754 compatible with denormal support
--                                  (NaN and denormal numbers are supported)
--
--   op_iso_mode      0 to 4        default: 0
--                                  Type of operand isolation
--                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
--                                    0 => Follow intent defined by Power Compiler user setting
--                                    1 => no operand isolation
--                                    2 => 'and' gate isolaton
--                                    3 => 'or' gate isolation
--                                    4 => preferred isolation style: 'and' gate
--
--   id_width        1 to 1024      default: 8
--                                  Launch identifier width
--
--   in_reg           0 to 1        default: 0
--                                  Input register control
--                                    0 => no input register
--                                    1 => include input register
--
--   stages          1 to 1022      default: 4
--                                  Number of logic stages in the pipeline
--
--   out_reg          0 to 1        default: 0
--                                  Output register control
--                                    0 => no output register
--                                    1 => include output register
--
--   no_pm            0 to 1        default: 1
--                                  Pipeline management usage
--                                    0 => Use pipeline management
--                                    1 => Do not use pipeline management - launch input
--                                          becomes global register enable to block
--
--   rst_mode        0 to 1         default: 0
--                                  Control asynchronous or synchronous reset
--                                  behavior of rst_n
--                                    0 => asynchronous reset
--                                    1 -> synchronous reset
--
--
--  Ports       Size          Direction    Description
--  =====       ====          =========    ===========
--  clk         1 bit           Input      Clock Input
--  rst_n       1 bit           Input      Reset Input, Active Low
--
--  a           (sig_width + exp_width + 1) bits    Input      Dividend
--  b           (sig_width + exp_width + 1) bits    Input      Divider
--  rnd         3 bits          Input      rounding mode
--  z           (sig_width + exp_width + 1) bits    Output     z = 1/a
--  status 8 bits         Output     status Flags Output ?
--
--  launch      1 bit           Input      Active High Control input to lauche data into pipe
--  launch_id   id_width bits   Input      ID tag for data being launched (optional)
--  pipe_full   1 bit           Output     status Flag indicating no slot for new data
--  pipe_ovf    1 bit           Output     status Flag indicating pipe overflow
--
--  accept_n    1 bit           Input      Flow Control Input, Active Low
--  arrive      1 bit           Output     Data Available output
--  arrive_id   id_width bits   Output     ID tag for data that's arrived (optional)
--  push_out_n  1 bit           Output     Active Low Output used with FIFO (optional)
--  pipe_census R bits          Output     Output bus indicating the number
--                                         of pipe stages currently occupied
--
--     Note: M is the value of "data_width" parameter
--     Note: N is the value of "chk_width" parameter
--     Note: Q is the value of "id_width" parameter
--     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
--  Modified:
--
--------------------------------------------------------------------------
 
library IEEE, DWARE, DW02;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_lp_piped_fp_add is
	
-- pragma translate_off


function calc_pms( in_reg, stages, out_reg : in INTEGER ) return INTEGER is
  begin
    if((in_reg+(stages-1)+out_reg) >= 1) then
      return (in_reg+(stages-1)+out_reg);
    else
      return(1);
    end if;
end calc_pms; -- pipe_mgr stages

constant pipe_mgr_stages  : INTEGER := calc_pms(in_reg, stages, out_reg);

signal OllO1lI0              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal l1l1IIl1              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal I0O00OOO            : std_logic_vector(2 downto 0);
signal IO1101IO         : std_logic;
signal I0O0IO0l      : std_logic_vector(id_width-1 downto 0);
signal lI11OIO0       : std_logic;

signal I00O0O11       : std_logic;
signal OlO1010O        : std_logic;
signal l0100IlO          : std_logic;
signal O00OlI1l       : std_logic_vector(id_width-1 downto 0);
signal OOO0l00O    : std_logic_vector(id_width-1 downto 0);
signal O00lO1IO      : std_logic;
signal OI1O110I     : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal llI000IO     : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);

signal Oll0lI10      : std_logic;
signal lO1O110l  : std_logic;
signal O11II0l1       : std_logic;
signal O001O0lO         : std_logic;
signal I00lIlI0      : std_logic_vector(id_width-1 downto 0);
signal O0OOOlO0     : std_logic;
signal O10l0011    : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal l00OlllO    : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);

signal OOI1Ol11            : std_logic_vector((sig_width + exp_width )+8 downto 0);
signal lOOI0O00           : std_logic_vector((sig_width + exp_width )+8 downto 0);

signal llIIO001              : std_logic_vector(sig_width + exp_width  downto 0);
signal O0lOOO01         : std_logic_vector(7 downto 0);

signal pipe_full_int      : std_logic;
signal pipe_ovf_int       : std_logic;
signal arrive_int         : std_logic;
signal arrive_id_int      : std_logic_vector(id_width-1 downto 0);
signal push_out_n_int     : std_logic;
signal I1l011IO    : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal pipe_census_int    : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);


signal pipe_en_in_bus_int  : std_logic;
signal pipe_en_out_bus_int : std_logic_vector(pipe_mgr_stages-1 downto 0);

constant pl_id_reg_en_msb  : integer := maximum(0, in_reg+stages+out_reg-2);
constant pl_reg_en_msb : integer := maximum(0, in_reg+stages+out_reg-2);
constant pl_reg_width  : integer := (sig_width + exp_width + 1)  +8;
constant word_of_Xs : std_logic_vector((sig_width + exp_width + 1)-1 downto 0) := (others => 'X');
constant word_of_Xs_id              : std_logic_vector(id_width-1 downto 0) := (others => 'X');

signal clk_int            : std_logic;
signal rst_n_a            : std_logic;
signal rst_n_s            : std_logic;
type   pipe_T    is array (0 to pl_reg_en_msb) of std_logic_vector(pl_reg_width-1 downto 0);
type   pipe_id_T is array (0 to pl_id_reg_en_msb) of std_logic_vector(id_width-1 downto 0);
signal lOOIO01l            : pipe_T;
signal pl_regs_id         : pipe_id_T;


-- pragma translate_on
begin
-- pragma translate_off

  clk_int <= To_X01(clk);
  rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
  rst_n_s <= To_X01(rst_n);
  OllO1lI0   <= To_X01(a);
  l1l1IIl1   <= To_X01(b);
  I0O00OOO <= To_X01(rnd);
  
  IO1101IO    <= To_X01(launch);
  I0O0IO0l <= To_X01(launch_id);
  lI11OIO0  <= To_X01(accept_n);
  



  OOO0l00O <= I0O0IO0l when ((in_reg+stages+out_reg) = 1) else pl_regs_id(pl_reg_en_msb);



  -- Instance of DW_fp_add
  U1 : DW_fp_add
	generic map (
		sig_width => sig_width,
		exp_width => exp_width,
		ieee_compliance => ieee_compliance
		)
	port map (
		a => OllO1lI0,
		b => l1l1IIl1,
		rnd => I0O00OOO,
		z => llIIO001,
		status => O0lOOO01
		);

  OOI1Ol11 <= (llIIO001 & (O0lOOO01 XOR "00000001"));
 



  lOOI0O00 <= OOI1Ol11 when ((in_reg+stages+out_reg) = 1) else lOOIO01l(pl_reg_en_msb);



  U2 : DW_lp_pipe_mgr
      generic map (
        stages => pipe_mgr_stages,
        id_width => id_width )
      port map (
        clk => clk_int,
        rst_n => rst_n_a,
        init_n => rst_n_s,
        launch => IO1101IO,
        launch_id => I0O0IO0l,
        accept_n => lI11OIO0,
        arrive => l0100IlO,
        arrive_id => O00OlI1l,
        pipe_en_bus => OI1O110I,
        pipe_full => I00O0O11,
        pipe_ovf => OlO1010O,
        push_out_n => O00lO1IO,
        pipe_census => llI000IO );


  O001O0lO         <= IO1101IO;
  I00lIlI0      <= I0O0IO0l;
  O10l0011    <= (others => '0');
  Oll0lI10      <= lI11OIO0;
  lO1O110l  <= Oll0lI10 AND O001O0lO;
  O0OOOlO0     <= NOT(NOT(lI11OIO0) AND IO1101IO);
  l00OlllO    <= (others => '0');
    
  pipe_ctrl_out_int1: process (l0100IlO, I00O0O11, OlO1010O, O00lO1IO, llI000IO,
                               O001O0lO, Oll0lI10, O11II0l1, O0OOOlO0, l00OlllO)
    begin
      if (no_pm=1) then
         arrive_int       <= '0';
         pipe_full_int    <= '0';
         pipe_ovf_int     <= '0';
         push_out_n_int   <= '0';
         pipe_census_int  <= (others => '0'); 
      else
         if ((in_reg+stages+out_reg) > 1) then
           arrive_int       <= l0100IlO;
           pipe_full_int    <= I00O0O11;
           pipe_ovf_int     <= OlO1010O;
           push_out_n_int   <= O00lO1IO;
           pipe_census_int  <= llI000IO;
         else
           arrive_int       <= O001O0lO;
           pipe_full_int    <= Oll0lI10;
           pipe_ovf_int     <= O11II0l1;
           push_out_n_int   <= O0OOOlO0;
           pipe_census_int  <= l00OlllO;
         end if;
      end if;
  end process pipe_ctrl_out_int1;

  pipe_ctrl_out_int2: process (OOO0l00O, O00OlI1l, OI1O110I,
                               I00lIlI0, O10l0011, launch)
    begin
      if ((in_reg+stages+out_reg) > 1) then
        if (no_pm=1) then
          arrive_id_int    <= OOO0l00O;
          I1l011IO  <= (others => launch);
        else
          arrive_id_int    <= O00OlI1l;
          I1l011IO  <= OI1O110I;
        end if;
      else
        arrive_id_int    <= I00lIlI0;
        I1l011IO  <= O10l0011;
      end if;
  end process pipe_ctrl_out_int2;


  pipe_en_in_bus_int <= I1l011IO(0);

  pipe_out_en_bus_PROC: process (I1l011IO)
    begin
      if (in_reg = 1) then
        pipe_en_out_bus_int(0) <= '0';
        for i in 1 to pipe_mgr_stages-1 loop
          pipe_en_out_bus_int(i-1) <= I1l011IO(i);
        end loop;
      else
        pipe_en_out_bus_int <= I1l011IO;
      end if;
  end process pipe_out_en_bus_PROC;


  sim_clk: process (clk_int, rst_n_a)
    variable i  : INTEGER;
    begin

      if (rst_n_a = '0') then
        O11II0l1 <= '0';
      elsif (rst_n_a = '1') then
	  if (rising_edge(clk_int)) then
          if (rst_n_s = '0') then
            O11II0l1 <= '0';
          elsif (rst_n_s = '1') then
            O11II0l1 <= lO1O110l;
          else
            O11II0l1 <= 'X';
          end if;
        end if;
      else
        O11II0l1 <= 'X';
	end if;

  end process;

  z           <= lOOI0O00((sig_width + exp_width +8) downto 8) when (arrive_int = '1' or no_pm = 1) else (others =>'X');
  status      <= lOOI0O00(7 downto 0) XOR "00000001" when (arrive_int = '1' or no_pm = 1) else (others =>'X');
  
  pipe_ovf    <= pipe_ovf_int;
  pipe_full   <= pipe_full_int;
  arrive      <= arrive_int;
  arrive_id   <= arrive_id_int;
  
  push_out_n  <= push_out_n_int;
  pipe_census <= pipe_census_int;


  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
  
    if ( (sig_width < 3) OR (sig_width > 253) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter sig_width (legal range: 3 to 253)"
        severity warning;
    end if;
  
    if ( (exp_width < 3) OR (exp_width > 31) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_width (legal range: 3 to 31)"
        severity warning;
    end if;
  
    if ( (ieee_compliance < 0) OR (ieee_compliance > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter ieee_compliance (legal range: 0 to 1)"
        severity warning;
    end if;
  
    if ( (op_iso_mode < 0) OR (op_iso_mode > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter op_iso_mode (legal range: 0 to 4)"
        severity warning;
    end if;
  
    if ( (id_width < 1) OR (id_width > 1024) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter id_width (legal range: 1 to 1024)"
        severity warning;
    end if;
  
    if ( (stages < 1) OR (stages > 1022) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter stages (legal range: 1 to 1022)"
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
  
    if ( (no_pm < 0) OR (no_pm > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter no_pm (legal range: 0 to 1)"
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

library dw02, dw03;

configuration DW_lp_piped_fp_add_cfg_sim of DW_lp_piped_fp_add is
 for sim
  for U1 : DW_fp_add use configuration dw02.DW_fp_add_cfg_sim; end for;
  for U2 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
 end for; -- sim
end DW_lp_piped_fp_add_cfg_sim;
-- pragma translate_on
