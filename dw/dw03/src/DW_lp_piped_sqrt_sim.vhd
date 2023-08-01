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
-- AUTHOR:    Bruce Dean    Sep. 20, 2007
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 7b57a29b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Low Power Pipelined Square Root Simulation Model
--
--           This receives an operand on which the square root operation is performed.
--           Configurable to provide pipeline registers for both static and re-timing 
--           placement.  Also, contains pipeline management to optimized for low power.
--
--
--  Parameters:     Valid Values    Description
--  ==========      ============    =============
--   width           >= 1           default: 8
--                                  Width of 'a' operand
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
--   tc_mode         0 to 1         default: 0
--                                  Two's complement control
--                                    0 => unsigned
--                                    1 => two's complement
--
--   rst_mode        0 to 1         default: 0
--                                  Control asynchronous or synchronous reset
--                                  behavior of rst_n
--                                    0 => asynchronous reset
--                                    1 -> synchronous reset
--
--   op_iso_mode      0 to 4        default: 0
--                                  Type of operand isolation 
--                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
--                                    0 => Follow intent defined by Power Compiler user setting
--                                    1 => no operand isolation
--                                    2 => 'and' gate operand isolaton
--                                    3 => 'or' gate operand isolation
--                                    4 => preferred isolation style: 'or'
--
--
--  Ports       Size          Direction    Description
--  =====       ====          =========    ===========
--  clk         1 bit           Input      Clock Input
--  rst_n       1 bit           Input      Reset Input, Active Low
--
--  a           width bits      Input      Radicand
--  root        M bits          Output     Square root of a
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
--     Note: M is equal to (width+1)/2
--     Note: R is equal to the the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
-- Modified:
--   2/21/08  DLL  Added 'op_iso_mode' parameter checking and special case
--                 driving of 'root' when 'launch' is not asserted.
--
--------------------------------------------------------------------------
 
library IEEE, DWARE, DW02;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_arith.DWF_sqrt;
use DWARE.DW_foundation_comp_arith.DW_lp_pipe_mgr;

architecture sim of DW_lp_piped_sqrt is
	
-- pragma translate_off


  function OO00II1I( in_reg, stages, out_reg : in INTEGER ) return INTEGER is
    begin
      if((in_reg+(stages-1)+out_reg) >= 1) then
        return (in_reg+(stages-1)+out_reg);
      else
        return(1);
      end if;
  end OO00II1I; -- pipe_mgr stages

  constant lIOIOI0I	: INTEGER := OO00II1I(in_reg, stages, out_reg);

  signal IOO1I001		: std_logic_vector(width-1 downto 0);
  signal l0IOOO01		: std_logic;
  signal lOO0OOIO		: std_logic_vector(id_width-1 downto 0);
  signal I1l0O00I		: std_logic;

  signal OI1O0II1		: std_logic;
  signal OO11lO1O		: std_logic;
  signal OII01lII		: std_logic;
  signal lIllO000		: std_logic_vector(id_width-1 downto 0);
  signal lI011I00		: std_logic;
  signal ll10100O		: std_logic_vector(lIOIOI0I-1 downto 0);
  signal llO1101O		: std_logic_vector(bit_width(lIOIOI0I+1)-1 downto 0);

  signal lO1IO0IO		: std_logic;
  signal O00I0I10		: std_logic;
  signal l1l1O1l1		: std_logic;
  signal I11O110l		: std_logic;
  signal I1lI10O1		: std_logic_vector(id_width-1 downto 0);
  signal OO1l1100		: std_logic;
  signal ll11I01I		: std_logic_vector(lIOIOI0I-1 downto 0);
  signal l11lIO0O		: std_logic_vector(bit_width(lIOIOI0I+1)-1 downto 0);

  signal O0O101O0		: std_logic_vector(((width+1)/2)-1 downto 0);
  signal I0O0I0O0		: std_logic_vector(((width+1)/2)-1 downto 0);
  signal l110101O		: std_logic_vector(((width+1)/2)-1 downto 0);
  signal O101Il00		: std_logic_vector(((width+1)/2)-1 downto 0);
  
  signal OI111100		: std_logic_vector(((width+1)/2)-1 downto 0);

  signal OO0O10ll		: std_logic;
  signal O01lO0OO		: std_logic;
  signal OOl1O10O		: std_logic;
  signal OO1lI1OI		: std_logic_vector(id_width-1 downto 0);
  signal lIII1Ol0		: std_logic;
  signal I0011010		: std_logic_vector(lIOIOI0I-1 downto 0);
  signal lO1OI11I		: std_logic_vector(bit_width(lIOIOI0I+1)-1 downto 0);


  constant OI11OOOO : integer := maximum(0, in_reg+stages+out_reg-2);
  constant OOll1O0O  : integer := (width+1)/2;
  constant l1O10l1I : std_logic_vector(width-1 downto 0) := (others => 'X');

  signal clk_int		: std_logic;
  signal rst_n_a		: std_logic;
  signal rst_n_s		: std_logic;
  type O0OOOO01 is array (0 to OI11OOOO) of std_logic_vector(OOll1O0O-1 downto 0);
  signal O1IOI1O1		: O0OOOO01;


-- pragma translate_on
begin
-- pragma translate_off

    clk_int <= To_X01(clk);
    rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
    rst_n_s <= To_X01(rst_n);
    IOO1I001 <= To_X01(a);
    l0IOOO01 <= To_X01(launch);
    lOO0OOIO <= To_X01(launch_id);
    I1l0O00I <= To_X01(accept_n);

    I0O0I0O0   <= conv_std_logic_vector(DWF_sqrt (unsigned(a)),OOll1O0O);
    O0O101O0    <= conv_std_logic_vector(DWF_sqrt (signed(a)),OOll1O0O);
    l110101O <= O0O101O0 when tc_mode = 1 else I0O0I0O0;




  O101Il00 <= l110101O when ((in_reg+stages+out_reg) = 1) else O1IOI1O1(OI11OOOO);



    U1 : DW_lp_pipe_mgr
        generic map (
          stages => lIOIOI0I,
          id_width => id_width )
        port map (
          clk => clk_int,
          rst_n => rst_n_a,
          init_n => rst_n_s,
          launch => l0IOOO01,
          launch_id => lOO0OOIO,
          accept_n => I1l0O00I,
          arrive => OII01lII,
          arrive_id => lIllO000,
          pipe_en_bus => ll10100O,
          pipe_full => OI1O0II1,
          pipe_ovf => OO11lO1O,
          push_out_n => lI011I00,
          pipe_census => llO1101O );


    I11O110l         <= l0IOOO01;
    I1lI10O1      <= lOO0OOIO;
    ll11I01I    <= (others => '0');
    lO1IO0IO      <= I1l0O00I;
    O00I0I10  <= lO1IO0IO AND I11O110l;
    OO1l1100     <= NOT(NOT(I1l0O00I) AND l0IOOO01);
    l11lIO0O    <= (others => '0');
      
      
    OOl1O10O       <= OII01lII       when ((in_reg+stages+out_reg) > 1) else I11O110l;
    OO1lI1OI    <= lIllO000    when ((in_reg+stages+out_reg) > 1) else I1lI10O1;
    I0011010  <= ll10100O  when ((in_reg+stages+out_reg) > 1) else ll11I01I;
    OO0O10ll    <= OI1O0II1    when ((in_reg+stages+out_reg) > 1) else lO1IO0IO;
    O01lO0OO     <= OO11lO1O     when ((in_reg+stages+out_reg) > 1) else l1l1O1l1;
    lIII1Ol0   <= lI011I00   when ((in_reg+stages+out_reg) > 1) else OO1l1100;
    lO1OI11I  <= llO1101O  when ((in_reg+stages+out_reg) > 1) else l11lIO0O;
    
    


    O1011011: process (clk_int, rst_n_a)
      variable i  : INTEGER;
      begin

        if (rst_n_a = '0') then
          l1l1O1l1 <= '0';
        elsif (rst_n_a = '1') then
	  if (rising_edge(clk_int)) then
            if (rst_n_s = '0') then
              l1l1O1l1 <= '0';
            elsif (rst_n_s = '1') then
              l1l1O1l1 <= O00I0I10;
            else
              l1l1O1l1 <= 'X';
            end if;
          end if;
        else
          l1l1O1l1 <= 'X';
	end if;

    end process;

    OI111100       <= (others => 'X');

    root          <= OI111100 when ((in_reg=0) AND (stages=1) AND (out_reg=0) AND (launch='0')) else O101Il00;
    pipe_ovf      <= O01lO0OO;
    pipe_full     <= OO0O10ll;
    arrive        <= OOl1O10O;
    arrive_id     <= OO1lI1OI;
    push_out_n    <= lIII1Ol0;
    pipe_census   <= lO1OI11I;


    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 1)"
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
    
    if ( (tc_mode < 0) OR (tc_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tc_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (rst_mode < 0) OR (rst_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rst_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (op_iso_mode < 0) OR (op_iso_mode > 4) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter op_iso_mode (legal range: 0 to 4)"
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

library dw03;

configuration DW_lp_piped_sqrt_cfg_sim of DW_lp_piped_sqrt is
 for sim
    for U1 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
 end for; -- sim
end DW_lp_piped_sqrt_cfg_sim;
-- pragma translate_on
