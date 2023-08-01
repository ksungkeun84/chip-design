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
-- DesignWare_version: 1ab6a960
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Low Power Pipelined Divider Simulation Model
--
--           This receives two operands that get sum3ided.  Configurable
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
--   arch_type         0 or 1       (default 0)
--
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
--  a           (sig_width + exp_width + 1) bits    Input      
--  b           (sig_width + exp_width + 1) bits    Input      
--  c           (sig_width + exp_width + 1) bits    Input      
--  rnd         3 bits          Input      rounding mode
--  z           (sig_width + exp_width + 1) bits    Output     z = a+b+c
--  status      8 bits          Output     status Flags Output 
--
--  launch      1 bit           Input      Active High Control input to lauche data into pipe
--  launch_id   id_width bits   Input      ID tag for data being launched (optional)
--  pipe_full   1 bit           Output     Status Flag indicating no slot for new data
--  pipe_ovf    1 bit           Output     Status Flag indicating pipe overflow
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

architecture sim of DW_lp_piped_fp_sum3 is
	
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

signal O0O0l10O              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal l0l001OO              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal O11OOI0O              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal O1l1OO0I            : std_logic_vector(2 downto 0);
signal O0OO00O0         : std_logic;
signal O0100OOO      : std_logic_vector(id_width-1 downto 0);
signal OOO0O0O0       : std_logic;

signal OI1Oll0O       : std_logic;
signal Ol0O1O1I        : std_logic;
signal OIO11O11          : std_logic;
signal O1lIIO01       : std_logic_vector(id_width-1 downto 0);
signal IO010I10    : std_logic_vector(id_width-1 downto 0);
signal l0O0OO10      : std_logic;
signal lO1OO1I0     : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal IO011000     : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);

signal O1lI1OOO      : std_logic;
signal lIII101O  : std_logic;
signal IO001IOO       : std_logic;
signal OOO1II00         : std_logic;
signal OOO011IO      : std_logic_vector(id_width-1 downto 0);
signal l010O0O0     : std_logic;
signal IO01lOOI    : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal I1110l1I    : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);

signal O11I1IOl            : std_logic_vector((sig_width + exp_width )+8 downto 0);
signal O0IOIOOO           : std_logic_vector((sig_width + exp_width )+8 downto 0);

signal II1001O0              : std_logic_vector(sig_width + exp_width  downto 0);
signal O011O1I0         : std_logic_vector(7 downto 0);

signal pipe_full_int      : std_logic;
signal pipe_ovf_int       : std_logic;
signal arrive_int         : std_logic;
signal arrive_id_int      : std_logic_vector(id_width-1 downto 0);
signal push_out_n_int     : std_logic;
signal Ol11IOIO    : std_logic_vector(pipe_mgr_stages-1 downto 0);
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
signal lI00l0O0            : pipe_T;
signal pl_regs_id         : pipe_id_T;


-- pragma translate_on
begin
-- pragma translate_off

  clk_int <= To_X01(clk);
  rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
  rst_n_s <= To_X01(rst_n);
  O0O0l10O   <= To_X01(a);
  l0l001OO   <= To_X01(b);
  O11OOI0O   <= To_X01(c);
  O1l1OO0I <= To_X01(rnd);
  
  O0OO00O0    <= To_X01(launch);
  O0100OOO <= To_X01(launch_id);
  OOO0O0O0  <= To_X01(accept_n);
  



  IO010I10 <= O0100OOO when ((in_reg+stages+out_reg) = 1) else pl_regs_id(pl_reg_en_msb);



  -- Instance of DW_fp_sum3
  U1 : DW_fp_sum3
	generic map (
		sig_width => sig_width,
		exp_width => exp_width,
		ieee_compliance => ieee_compliance,
		arch_type => arch_type
		)
	port map (
		a => O0O0l10O,
		b => l0l001OO,
		c => O11OOI0O,
		rnd => O1l1OO0I,
		z => II1001O0,
		status => O011O1I0
		);

  O11I1IOl <= (II1001O0 & (O011O1I0 XOR "00000001"));
 



  O0IOIOOO <= O11I1IOl when ((in_reg+stages+out_reg) = 1) else lI00l0O0(pl_reg_en_msb);



  U2 : DW_lp_pipe_mgr
      generic map (
        stages => pipe_mgr_stages,
        id_width => id_width )
      port map (
        clk => clk_int,
        rst_n => rst_n_a,
        init_n => rst_n_s,
        launch => O0OO00O0,
        launch_id => O0100OOO,
        accept_n => OOO0O0O0,
        arrive => OIO11O11,
        arrive_id => O1lIIO01,
        pipe_en_bus => lO1OO1I0,
        pipe_full => OI1Oll0O,
        pipe_ovf => Ol0O1O1I,
        push_out_n => l0O0OO10,
        pipe_census => IO011000 );


  OOO1II00         <= O0OO00O0;
  OOO011IO      <= O0100OOO;
  IO01lOOI    <= (others => '0');
  O1lI1OOO      <= OOO0O0O0;
  lIII101O  <= O1lI1OOO AND OOO1II00;
  l010O0O0     <= NOT(NOT(OOO0O0O0) AND O0OO00O0);
  I1110l1I    <= (others => '0');
    
  pipe_ctrl_out_int1: process (OIO11O11, OI1Oll0O, Ol0O1O1I, l0O0OO10, IO011000,
                               OOO1II00, O1lI1OOO, IO001IOO, l010O0O0, I1110l1I)
    begin
      if (no_pm=1) then
         arrive_int       <= '0';
         pipe_full_int    <= '0';
         pipe_ovf_int     <= '0';
         push_out_n_int   <= '0';
         pipe_census_int  <= (others => '0'); 
      else
         if ((in_reg+stages+out_reg) > 1) then
           arrive_int       <= OIO11O11;
           pipe_full_int    <= OI1Oll0O;
           pipe_ovf_int     <= Ol0O1O1I;
           push_out_n_int   <= l0O0OO10;
           pipe_census_int  <= IO011000;
         else
           arrive_int       <= OOO1II00;
           pipe_full_int    <= O1lI1OOO;
           pipe_ovf_int     <= IO001IOO;
           push_out_n_int   <= l010O0O0;
           pipe_census_int  <= I1110l1I;
         end if;
      end if;
  end process pipe_ctrl_out_int1;

  pipe_ctrl_out_int2: process (IO010I10, O1lIIO01, lO1OO1I0,
                               OOO011IO, IO01lOOI, launch)
    begin
      if ((in_reg+stages+out_reg) > 1) then
        if (no_pm=1) then
          arrive_id_int    <= IO010I10;
          Ol11IOIO  <= (others => launch);
        else
          arrive_id_int    <= O1lIIO01;
          Ol11IOIO  <= lO1OO1I0;
        end if;
      else
        arrive_id_int    <= OOO011IO;
        Ol11IOIO  <= IO01lOOI;
      end if;
  end process pipe_ctrl_out_int2;


  pipe_en_in_bus_int <= Ol11IOIO(0);

  pipe_out_en_bus_PROC: process (Ol11IOIO)
    begin
      if (in_reg = 1) then
        pipe_en_out_bus_int(0) <= '0';
        for i in 1 to pipe_mgr_stages-1 loop
          pipe_en_out_bus_int(i-1) <= Ol11IOIO(i);
        end loop;
      else
        pipe_en_out_bus_int <= Ol11IOIO;
      end if;
  end process pipe_out_en_bus_PROC;


  sim_clk: process (clk_int, rst_n_a)
    variable i  : INTEGER;
    begin

      if (rst_n_a = '0') then
        IO001IOO <= '0';
      elsif (rst_n_a = '1') then
	  if (rising_edge(clk_int)) then
          if (rst_n_s = '0') then
            IO001IOO <= '0';
          elsif (rst_n_s = '1') then
            IO001IOO <= lIII101O;
          else
            IO001IOO <= 'X';
          end if;
        end if;
      else
        IO001IOO <= 'X';
	end if;

  end process;

  z           <= O0IOIOOO((sig_width + exp_width +8) downto 8);
  status      <= O0IOIOOO(7 downto 0) XOR "00000001";
  
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
  
    if ( (arch_type < 0) OR (arch_type > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter arch_type (legal range: 0 to 1)"
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

configuration DW_lp_piped_fp_sum3_cfg_sim of DW_lp_piped_fp_sum3 is
 for sim
  for U1 : DW_fp_sum3 use configuration dw02.DW_fp_sum3_cfg_sim; end for;
  for U2 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
 end for; -- sim
end DW_lp_piped_fp_sum3_cfg_sim;
-- pragma translate_on
