--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2008 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean    Sep. 20, 2007
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 3fa07d2f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Low Power Pipelined divider Simulation Model
--
--           This receives two operands that get diviplied.  Configurable
--           to provide pipeline registers for both static and re-timing placement.
--           Also, contains pipeline management to optimized for low power.
--
--
--  Parameters:     Valid Values    Description
--  ==========      ============    =============
--   a_width           >= 1         default: 8
--                                  Width of 'a' operand
--
--   b_width           >= 1         default: 8
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
--   rem_mode        0 or 1         default: 0
--                                  Remainder output control:
--                                    0 : remainder output is VHDL modulus
--                                    1 : remainder output is remainder
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
--  a           a_width bits    Input      dividend
--  b           b_width bits    Input	   divisor
--  quotient    a_width bits    Output     quotient a / b
--  rem         b_width bits    Output     rem a / b
--  div_by_0    1 bit           Output     high when b input is zero
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
--     Note: R is equal to the the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
-- Modified:
--
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_arith.DWF_div;
use DWARE.DW_foundation_arith.DWF_rem;
use DWARE.DW_foundation_arith.DWF_mod;
use DWARE.DW_foundation_comp_arith.DW_lp_pipe_mgr;

architecture sim of DW_lp_piped_div is
	
-- pragma translate_off


  function I1O1O1Il( in_reg, stages, out_reg : in INTEGER ) return INTEGER is
    begin
        if((in_reg+(stages-1)+out_reg) >= 1) then
          return (in_reg+(stages-1)+out_reg);
        else
          return(1);
        end if;
  end I1O1O1Il;

  constant Ol0O0l10  : INTEGER := I1O1O1Il(in_reg, stages, out_reg);

  signal OOlO001O		: std_logic_vector(a_width-1 downto 0);
  signal O0lOOI0O		: std_logic_vector(b_width-1 downto 0);
  signal O1O10ll0		: std_logic;
  signal I1lIOO00		: std_logic_vector(id_width-1 downto 0);
  signal l0Ol1l1l		: std_logic;

  signal I0110Ol1		: std_logic;
  signal O010001I		: std_logic;
  signal I0O11111		: std_logic;
  signal l0l010I1		: std_logic_vector(id_width-1 downto 0);
  signal OII0lO11		: std_logic;
  signal O10l0I1O		: std_logic_vector(Ol0O0l10-1 downto 0);
  signal l1l1I10O		: std_logic_vector(bit_width(Ol0O0l10+1)-1 downto 0);

  signal O101O111		: std_logic;
  signal lOI1Ol1I		: std_logic;
  signal O1OI100l		: std_logic;
  signal IO0l001O		: std_logic;
  signal IOOlOl1I		: std_logic_vector(id_width-1 downto 0);
  signal lO111l11		: std_logic;
  signal l001OO10		: std_logic_vector(Ol0O0l10-1 downto 0);
  signal I10OO110		: std_logic_vector(bit_width(Ol0O0l10+1)-1 downto 0);

  signal l01OO110		: signed(a_width-1 downto 0);
  signal O10l10lO		: unsigned(a_width-1 downto 0);
  signal l0OI1O10		: std_logic_vector(a_width+b_width downto 0);
  signal I0I1111O		: std_logic_vector(a_width+b_width downto 0);
  
  signal lO1100OO		: std_logic_vector(a_width-1 downto 0);
  signal OOI1O100		: std_logic_vector(a_width-1 downto 0);
  signal I0Ol0l0I		: std_logic_vector(b_width-1 downto 0);
  signal lI00O1OI		: std_logic_vector(b_width-1 downto 0);
  signal O1lll0O0		: std_logic;
  signal I0lIO0II		: std_logic;

  signal Ol11OOOO		: std_logic;
  signal O100O10I		: std_logic;
  signal O1l01O10		: std_logic;
  signal I1OO0IO1		: std_logic_vector(id_width-1 downto 0);
  signal O0lOOl10		: std_logic;
  signal lOI00O01		: std_logic_vector(Ol0O0l10-1 downto 0);
  signal OII011OI		: std_logic_vector(bit_width(Ol0O0l10+1)-1 downto 0);


  constant IIO0IO1O  : integer := maximum(0, in_reg+stages+out_reg-2);
  constant OOIOI1O1  : integer := a_width + b_width +1;
  constant OI11001O  : std_logic_vector(a_width-1 downto 0) := (others => 'X');

  signal clk_int		: std_logic;
  signal rst_n_a		: std_logic;
  signal rst_n_s		: std_logic;
  type O10Il111 is array (0 to IIO0IO1O) of std_logic_vector(OOIOI1O1-1 downto 0);
  signal l0lIlI11		: O10Il111;


-- pragma translate_on
begin
-- pragma translate_off

    clk_int <= To_X01(clk);
    rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
    rst_n_s <= To_X01(rst_n);
    OOlO001O <= To_X01(a);
    O0lOOI0O <= To_X01(b);
    O1O10ll0 <= To_X01(launch);
    I1lIOO00 <= To_X01(launch_id);
    l0Ol1l1l <= To_X01(accept_n);

   
  div: process (a, b)
  begin
    if tc_mode = 0 then
      lO1100OO <= std_logic_vector(DWF_div (unsigned(a), unsigned(b)));
      if rem_mode = 1 then
        I0Ol0l0I <= std_logic_vector(DWF_rem (unsigned(a), unsigned(b)));
      else
        I0Ol0l0I <= std_logic_vector(DWF_mod (unsigned(a), unsigned(b)));
      end if;
    else
      lO1100OO <= std_logic_vector(DWF_div (signed(a), signed(b)));
      if rem_mode = 1 then
        I0Ol0l0I <= std_logic_vector(DWF_rem (signed(a), signed(b)));
      else
        I0Ol0l0I <= std_logic_vector(DWF_mod (signed(a), signed(b)));
      end if;
    end if;
    if Is_X (b) then
      O1lll0O0 <= 'X';
    elsif unsigned(b) = 0 then
      O1lll0O0 <= '1';
    else
      O1lll0O0 <= '0';
    end if;
  end process div;

  l0OI1O10 <= (lO1100OO & I0Ol0l0I & O1lll0O0);




  I0I1111O <= l0OI1O10 when ((in_reg+stages+out_reg) = 1) else l0lIlI11(IIO0IO1O);



    U1 : DW_lp_pipe_mgr
        generic map (
          stages => Ol0O0l10,
          id_width => id_width )
        port map (
          clk => clk_int,
          rst_n => rst_n_a,
          init_n => rst_n_s,
          launch => O1O10ll0,
          launch_id => I1lIOO00,
          accept_n => l0Ol1l1l,
          arrive => I0O11111,
          arrive_id => l0l010I1,
          pipe_en_bus => O10l0I1O,
          pipe_full => I0110Ol1,
          pipe_ovf => O010001I,
          push_out_n => OII0lO11,
          pipe_census => l1l1I10O );


    IO0l001O	<= O1O10ll0;
    IOOlOl1I	<= I1lIOO00;
    l001OO10	<= (others => '0');
    O101O111	<= l0Ol1l1l;
    lOI1Ol1I	<= O101O111 AND IO0l001O;
    lO111l11	<= NOT(NOT(l0Ol1l1l) AND O1O10ll0);
    I10OO110	<= (others => '0');
      
      
    O1l01O10	<= I0O11111       when ((in_reg+stages+out_reg) > 1) else IO0l001O;
    I1OO0IO1	<= l0l010I1 when ((in_reg+stages+out_reg) > 1) else IOOlOl1I;
    lOI00O01	<= O10l0I1O when ((in_reg+stages+out_reg) > 1) else l001OO10;
    Ol11OOOO	<= I0110Ol1 when ((in_reg+stages+out_reg) > 1) else O101O111;
    O100O10I	<= O010001I when ((in_reg+stages+out_reg) > 1) else O1OI100l;
    O0lOOl10	<= OII0lO11 when ((in_reg+stages+out_reg) > 1) else lO111l11;
    OII011OI	<= l1l1I10O when ((in_reg+stages+out_reg) > 1) else I10OO110;
    
    


    lO1lI10O: process (clk_int, rst_n_a)
      variable lOO0OO1O  : INTEGER;
      begin

        if (rst_n_a = '0') then
          O1OI100l <= '0';
        elsif (rst_n_a = '1') then
	  if (rising_edge(clk_int)) then
            if (rst_n_s = '0') then
              O1OI100l <= '0';
            elsif (rst_n_s = '1') then
              O1OI100l <= lOI1Ol1I;
            else
              O1OI100l <= 'X';
            end if;
          end if;
        else
          O1OI100l <= 'X';
	end if;

    end process;


    OOI1O100	<= (others => 'X');
    lI00O1OI	<= (others => 'X');
    I0lIO0II	<= 'X';

    quotient      <= OOI1O100 when ((in_reg=0) AND (stages=1) AND (out_reg=0) AND (launch='0')) else 
                       I0I1111O(a_width+b_width downto b_width + 1);
    remainder     <= lI00O1OI when ((in_reg=0) AND (stages=1) AND (out_reg=0) AND (launch='0')) else 
                       I0I1111O(b_width downto 1);
    div_by_0      <= I0lIO0II when ((in_reg=0) AND (stages=1) AND (out_reg=0) AND (launch='0')) else 
                       I0I1111O(0);
    pipe_ovf      <= O100O10I;
    pipe_full     <= Ol11OOOO;
    arrive        <= O1l01O10;
    arrive_id     <= I1OO0IO1;
    push_out_n    <= O0lOOl10;
    pipe_census   <= OII011OI;


    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (a_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter a_width (lower bound: 1)"
        severity warning;
    end if;
    
    if (b_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter b_width (lower bound: 1)"
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
    
    if ( (rem_mode < 0) OR (rem_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rem_mode (legal range: 0 to 1)"
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

configuration DW_lp_piped_div_cfg_sim of DW_lp_piped_div is
 for sim
    for U1 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
 end for; -- sim
end DW_lp_piped_div_cfg_sim;
-- pragma translate_on
