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
-- AUTHOR:    Bruce Dean Oct 8 2008
--
-- VERSION:   Entity
--
-- DesignWare_version: 7b835cc5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Low Power Pipelined Divider Simulation Model
--
--           This receives two operands that get multided.  Configurable
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
--  status      8 bits          Output     status Flags Output ?
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

architecture sim of DW_lp_piped_fp_mult is
	
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

signal l11lIO00              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal l00llO00              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal I1100O11            : std_logic_vector(2 downto 0);
signal OI10lO01         : std_logic;
signal O1O0O11O      : std_logic_vector(id_width-1 downto 0);
signal OI1OlO00       : std_logic;

signal lIl001O1       : std_logic;
signal OOI0OO1O        : std_logic;
signal OI01IlOO          : std_logic;
signal O0OlO1l1       : std_logic_vector(id_width-1 downto 0);
signal O1II1l1l    : std_logic_vector(id_width-1 downto 0);
signal OIO1Il0l      : std_logic;
signal l11lOO1l     : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal O10010Ol     : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);

signal Ol1O1O10      : std_logic;
signal O001lIO1  : std_logic;
signal OIOO1Ol1       : std_logic;
signal Ol000110         : std_logic;
signal IOI0O01l      : std_logic_vector(id_width-1 downto 0);
signal l1O0OOl0     : std_logic;
signal OI00l01O    : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal l0I1011I    : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);

signal OO1101Ol            : std_logic_vector((sig_width + exp_width )+8 downto 0);
signal l1I011OI           : std_logic_vector((sig_width + exp_width )+8 downto 0);

signal O0Ol00I1              : std_logic_vector(sig_width + exp_width  downto 0);
signal I0I0001l         : std_logic_vector(7 downto 0);

signal pipe_full_int      : std_logic;
signal pipe_ovf_int       : std_logic;
signal arrive_int         : std_logic;
signal arrive_id_int      : std_logic_vector(id_width-1 downto 0);
signal push_out_n_int     : std_logic;
signal O1I01OO0    : std_logic_vector(pipe_mgr_stages-1 downto 0);
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
signal IOIOO1I0            : pipe_T;
signal pl_regs_id         : pipe_id_T;


-- pragma translate_on
begin
-- pragma translate_off

  clk_int <= To_X01(clk);
  rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
  rst_n_s <= To_X01(rst_n);
  l11lIO00   <= To_X01(a);
  l00llO00   <= To_X01(b);
  I1100O11 <= To_X01(rnd);
  
  OI10lO01    <= To_X01(launch);
  O1O0O11O <= To_X01(launch_id);
  OI1OlO00  <= To_X01(accept_n);
  



  O1II1l1l <= O1O0O11O when ((in_reg+stages+out_reg) = 1) else pl_regs_id(pl_reg_en_msb);



  -- Instance of DW_fp_mult
  U1 : DW_fp_mult
	generic map (
		sig_width => sig_width,
		exp_width => exp_width,
		ieee_compliance => ieee_compliance
		)
	port map (
		a => l11lIO00,
		b => l00llO00,
		rnd => I1100O11,
		z => O0Ol00I1,
		status => I0I0001l
		);

  OO1101Ol <= (O0Ol00I1 & (I0I0001l XOR "00000001"));
 



  l1I011OI <= OO1101Ol when ((in_reg+stages+out_reg) = 1) else IOIOO1I0(pl_reg_en_msb);



  U2 : DW_lp_pipe_mgr
      generic map (
        stages => pipe_mgr_stages,
        id_width => id_width )
      port map (
        clk => clk_int,
        rst_n => rst_n_a,
        init_n => rst_n_s,
        launch => OI10lO01,
        launch_id => O1O0O11O,
        accept_n => OI1OlO00,
        arrive => OI01IlOO,
        arrive_id => O0OlO1l1,
        pipe_en_bus => l11lOO1l,
        pipe_full => lIl001O1,
        pipe_ovf => OOI0OO1O,
        push_out_n => OIO1Il0l,
        pipe_census => O10010Ol );


  Ol000110         <= OI10lO01;
  IOI0O01l      <= O1O0O11O;
  OI00l01O    <= (others => '0');
  Ol1O1O10      <= OI1OlO00;
  O001lIO1  <= Ol1O1O10 AND Ol000110;
  l1O0OOl0     <= NOT(NOT(OI1OlO00) AND OI10lO01);
  l0I1011I    <= (others => '0');
    
  pipe_ctrl_out_int1: process (OI01IlOO, lIl001O1, OOI0OO1O, OIO1Il0l, O10010Ol,
                               Ol000110, Ol1O1O10, OIOO1Ol1, l1O0OOl0, l0I1011I)
    begin
      if (no_pm=1) then
         arrive_int       <= '0';
         pipe_full_int    <= '0';
         pipe_ovf_int     <= '0';
         push_out_n_int   <= '0';
         pipe_census_int  <= (others => '0'); 
      else
         if ((in_reg+stages+out_reg) > 1) then
           arrive_int       <= OI01IlOO;
           pipe_full_int    <= lIl001O1;
           pipe_ovf_int     <= OOI0OO1O;
           push_out_n_int   <= OIO1Il0l;
           pipe_census_int  <= O10010Ol;
         else
           arrive_int       <= Ol000110;
           pipe_full_int    <= Ol1O1O10;
           pipe_ovf_int     <= OIOO1Ol1;
           push_out_n_int   <= l1O0OOl0;
           pipe_census_int  <= l0I1011I;
         end if;
      end if;
  end process pipe_ctrl_out_int1;

  pipe_ctrl_out_int2: process (O1II1l1l, O0OlO1l1, l11lOO1l,
                               IOI0O01l, OI00l01O, launch)
    begin
      if ((in_reg+stages+out_reg) > 1) then
        if (no_pm=1) then
          arrive_id_int    <= O1II1l1l;
          O1I01OO0  <= (others => launch);
        else
          arrive_id_int    <= O0OlO1l1;
          O1I01OO0  <= l11lOO1l;
        end if;
      else
        arrive_id_int    <= IOI0O01l;
        O1I01OO0  <= OI00l01O;
      end if;
  end process pipe_ctrl_out_int2;


  pipe_en_in_bus_int <= O1I01OO0(0);

  pipe_out_en_bus_PROC: process (O1I01OO0)
    begin
      if (in_reg = 1) then
        pipe_en_out_bus_int(0) <= '0';
        for i in 1 to pipe_mgr_stages-1 loop
          pipe_en_out_bus_int(i-1) <= O1I01OO0(i);
        end loop;
      else
        pipe_en_out_bus_int <= O1I01OO0;
      end if;
  end process pipe_out_en_bus_PROC;


  sim_clk: process (clk_int, rst_n_a)
    variable i  : INTEGER;
    begin

      if (rst_n_a = '0') then
        OIOO1Ol1 <= '0';
      elsif (rst_n_a = '1') then
	  if (rising_edge(clk_int)) then
          if (rst_n_s = '0') then
            OIOO1Ol1 <= '0';
          elsif (rst_n_s = '1') then
            OIOO1Ol1 <= O001lIO1;
          else
            OIOO1Ol1 <= 'X';
          end if;
        end if;
      else
        OIOO1Ol1 <= 'X';
	end if;

  end process;

  z           <= l1I011OI((sig_width + exp_width +8) downto 8);
  status      <= l1I011OI(7 downto 0) XOR "00000001";
  
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

configuration DW_lp_piped_fp_mult_cfg_sim of DW_lp_piped_fp_mult is
 for sim
  for U1 : DW_fp_mult use configuration dw02.DW_fp_mult_cfg_sim; end for;
  for U2 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
 end for; -- sim
end DW_lp_piped_fp_mult_cfg_sim;
-- pragma translate_on
