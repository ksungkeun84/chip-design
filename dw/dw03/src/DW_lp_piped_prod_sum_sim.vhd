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
-- AUTHOR:    Doug Lee    Jan 2, 2008
--
-- VERSION:   Entity
--
-- DesignWare_version: 100f35a8
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--
-- ABSTRACT: Low Power Pipelined Sum of Products Simulation Model
--
--           This receives two set of 'concatenated' operands that result
--           in a summation from a set of products.  Configurable to provide
--           pipeline registers for both static and re-timing placement.
--           Also, contains pipeline management to optimized for low power.
--
--
--  Parameters:     Valid Values    Description
--  ==========      ============    =============
--   a_width           >= 1         default: 8
--                                  Width of 'a' operand
--
--   b_width           >= 1         default: 8
--                                  Width of 'b' operand
--
--   num_inputs        >= 1         default: 2
--                                  Number of inputs each in 'a' and 'b'
--
--   sum_width         >= 1         default: 17
--                                  Width of 'sum' result
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
--   tc_mode          0 to 1        default: 0
--                                  Two's complement control
--                                    0 => unsigned
--                                    1 => two's complement
--
--   rst_mode         0 to 1        default: 0
--                                  Control asynchronous or synchronous reset
--                                  behavior of rst_n
--                                    0 => asynchronous reset
--                                    1 => synchronous reset
--
--   op_iso_mode      0 to 4        default: 0
--                                  Type of operand isolation
--                                    If 'in_reg' is '1', this parameter is ignored...effectively set to '1'.
--                                    0 => Follow intent defined by Power Compiler user setting
--                                    1 => no operand isolation
--                                    2 => 'and' gate operand isolaton
--                                    3 => 'or' gate operand isolation
--                                    4 => preferred isolation style: 'and'
--
--
--  Ports       Size    Direction    Description
--  =====       ====    =========    ===========
--  clk         1 bit     Input      Clock Input
--  rst_n       1 bit     Input      Reset Input, Active Low
--
--  a           M bits    Input      Concatenated multiplier(s)
--  b           N bits    Input      Concatenated multipicand(s)
--  sum         P bits    Output     Sum of products
--
--  launch      1 bit     Input      Active High Control input to launch data into pipe
--  launch_id   Q bits    Input      ID tag for operation being launched
--  pipe_full   1 bit     Output     Status Flag indicating no slot for a new launch
--  pipe_ovf    1 bit     Output     Status Flag indicating pipe overflow
--
--  accept_n    1 bit     Input      Flow Control Input, Active Low
--  arrive      1 bit     Output     Product available output
--  arrive_id   Q bits    Output     ID tag for product that has arrived
--  push_out_n  1 bit     Output     Active Low Output used with FIFO
--  pipe_census R bits    Output     Output bus indicating the number
--                                   of pipeline register levels currently occupied
--
--     Note: M is "a_width x num_inputs"
--     Note: N is "b_width x num_inputs"
--     Note: P is the value of "sum_width" parameter
--     Note: Q is the value of "id_width" parameter
--     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
-- Modified:
--
---------------------------------------------------------------------------------------------
library IEEE,DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_lp_piped_prod_sum is
	
-- pragma translate_off


  function O01lO0l0( in_reg, stages, out_reg : in INTEGER ) return INTEGER is
    begin
        if((in_reg+(stages-1)+out_reg) >= 1) then
          return (in_reg+(stages-1)+out_reg);
        else
          return(1);
        end if;
  end O01lO0l0; -- pipe_mgr stages

  constant l1l1001l  : INTEGER := O01lO0l0(in_reg, stages, out_reg);

  subtype OlOOIOOI is
    SIGNED(a_width+b_width-1 downto 0);  
  subtype lOlIIOl0 is
    UNSIGNED(a_width+b_width-1 downto 0);      
  subtype O100IOO1 is
    UNSIGNED(sum_width-1 downto 0);
  subtype l10001I1 is
    SIGNED(sum_width-1 downto 0); 

  signal Il1OOII0              : std_logic_vector((a_width*num_inputs)-1 downto 0);
  signal Il0O0O00              : std_logic_vector((b_width*num_inputs)-1 downto 0);
  signal lOO1I00O         : std_logic;
  signal I110l1O0      : std_logic_vector(id_width-1 downto 0);
  signal I01O0IlI       : std_logic;

  signal l0O0OO10          : std_logic_vector(sum_width-1 downto 0);
  signal IlIOI0ll         : std_logic_vector(sum_width-1 downto 0);
  signal IO0OO1Ol             : std_logic_vector(sum_width-1 downto 0);

  signal I1011OI0       : std_logic;
  signal O1O0lll0        : std_logic;
  signal O0IOl101          : std_logic;
  signal O1IOOl0O       : std_logic_vector(id_width-1 downto 0);
  signal IIOOOO01      : std_logic;
  signal OIOl11O1     : std_logic_vector(l1l1001l-1 downto 0);
  signal OO0O0O01     : std_logic_vector(bit_width(l1l1001l+1)-1 downto 0);

  signal l101I1l1      : std_logic;
  signal O101lO0O  : std_logic;
  signal OO0I00I0       : std_logic;
  signal Ol0I1OlO         : std_logic;
  signal OO1O110I      : std_logic_vector(id_width-1 downto 0);
  signal O1l1O00I     : std_logic;
  signal l0I0OO1O    : std_logic_vector(l1l1001l-1 downto 0);
  signal OI10OOO0    : std_logic_vector(bit_width(l1l1001l+1)-1 downto 0);

  signal III010ll      : std_logic;
  signal I1OOIO0I       : std_logic;
  signal O0I100O1         : std_logic;
  signal ll010OOI      : std_logic_vector(id_width-1 downto 0);
  signal O0O101OO     : std_logic;
  signal lO10OO0I    : std_logic_vector(l1l1001l-1 downto 0);
  signal O1l00O0I    : std_logic_vector(bit_width(l1l1001l+1)-1 downto 0);


  constant lIOI011O : integer := maximum(0, in_reg+stages+out_reg-2);
  constant l001O0OO : std_logic_vector(sum_width-1 downto 0) := (others => 'X');

  signal clk_int            : std_logic;
  signal rst_n_a            : std_logic;
  signal rst_n_s            : std_logic;
  type l0II1111 is array (0 to lIOI011O) of std_logic_vector(sum_width-1 downto 0);
  signal O0l10l11 : l0II1111;


-- pragma translate_on
begin
-- pragma translate_off

    clk_int <= To_X01(clk);
    rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
    rst_n_s <= To_X01(rst_n);
    Il1OOII0 <= To_X01(a);
    Il0O0O00 <= To_X01(b);
    lOO1I00O <= To_X01(launch);
    I110l1O0 <= To_X01(launch_id);
    I01O0IlI <= To_X01(accept_n);


  O1I11lOl: process (Il1OOII0, Il0O0O00)
    variable I1010001: lOlIIOl0;
    variable O11I10IO: OlOOIOOI;    
    variable lOO1lO00, lO100110: O100IOO1;
    variable OOOO111I, IlO0l010: l10001I1;
  begin 
    if (tc_mode = 0) then
      lOO1lO00 := O100IOO1'(others => '0');
      for Ol0I1OO0 in 0 to num_inputs-1 loop
        I1010001 := UNSIGNED(Il1OOII0((Ol0I1OO0+1)*a_width-1 downto Ol0I1OO0*a_width)) *
     	           UNSIGNED(Il0O0O00((Ol0I1OO0+1)*b_width-1 downto Ol0I1OO0*b_width)); 
	if SUM_width > a_width+b_width then
	  lO100110(a_width+b_width-1 downto 0) := I1010001;
	  for Ol0I1OO0 in a_width+b_width to SUM_width-1 loop
	    lO100110(Ol0I1OO0) := '0';
	  end loop; 
	  lOO1lO00 := lOO1lO00 + lO100110;
	else
	  lOO1lO00 := lOO1lO00 + I1010001(SUM_width-1 downto 0);
	end if;
      end loop;
      l0O0OO10 <= std_logic_vector(lOO1lO00);
    else
      OOOO111I := l10001I1'(others => '0');
      for Ol0I1OO0 in 0 to num_inputs-1 loop
        O11I10IO := SIGNED(Il1OOII0((Ol0I1OO0+1)*a_width-1 downto Ol0I1OO0*a_width)) *
                   SIGNED(Il0O0O00((Ol0I1OO0+1)*b_width-1 downto Ol0I1OO0*b_width)); 
	if SUM_width > a_width+b_width then
	  IlO0l010(a_width+b_width-1 downto 0) := O11I10IO;
	  for Ol0I1OO0 in a_width+b_width to SUM_width-1 loop
	    IlO0l010(Ol0I1OO0) := O11I10IO(a_width+b_width-1);
	  end loop; 
	  OOOO111I := OOOO111I + IlO0l010;
	else
	  OOOO111I := OOOO111I + O11I10IO(SUM_width-1 downto 0);
	end if;
      end loop;
      l0O0OO10 <= std_logic_vector(OOOO111I);
    end if;
  end process;




  IlIOI0ll <= l0O0OO10 when ((in_reg+stages+out_reg) = 1) else O0l10l11(lIOI011O);



    U1 : DW_lp_pipe_mgr
        generic map (
          stages => l1l1001l,
          id_width => id_width )
        port map (
          clk => clk_int,
          rst_n => rst_n_a,
          init_n => rst_n_s,
          launch => lOO1I00O,
          launch_id => I110l1O0,
          accept_n => I01O0IlI,
          arrive => O0IOl101,
          arrive_id => O1IOOl0O,
          pipe_en_bus => OIOl11O1,
          pipe_full => I1011OI0,
          pipe_ovf => O1O0lll0,
          push_out_n => IIOOOO01,
          pipe_census => OO0O0O01 );


    Ol0I1OlO         <= lOO1I00O;
    OO1O110I      <= I110l1O0;
    l0I0OO1O    <= (others => '0');
    l101I1l1      <= I01O0IlI;
    O101lO0O  <= l101I1l1 AND Ol0I1OlO;
    O1l1O00I     <= NOT(NOT(I01O0IlI) AND lOO1I00O);
    OI10OOO0    <= (others => '0');


    O0I100O1       <= O0IOl101       when ((in_reg+stages+out_reg) > 1) else Ol0I1OlO;
    ll010OOI    <= O1IOOl0O    when ((in_reg+stages+out_reg) > 1) else OO1O110I;
    lO10OO0I  <= OIOl11O1  when ((in_reg+stages+out_reg) > 1) else l0I0OO1O;
    III010ll    <= I1011OI0    when ((in_reg+stages+out_reg) > 1) else l101I1l1;
    I1OOIO0I     <= O1O0lll0     when ((in_reg+stages+out_reg) > 1) else OO0I00I0;
    O0O101OO   <= IIOOOO01   when ((in_reg+stages+out_reg) > 1) else O1l1O00I;
    O1l00O0I  <= OO0O0O01  when ((in_reg+stages+out_reg) > 1) else OI10OOO0;


    Ol010OO1: process (clk_int, rst_n_a)
      variable Ol0I1OO0  : INTEGER;
      begin

        if (rst_n_a = '0') then
          OO0I00I0 <= '0';
        elsif (rst_n_a = '1') then
          if (rising_edge(clk_int)) then
            if (rst_n_s = '0') then
              OO0I00I0 <= '0';
            elsif (rst_n_s = '1') then
              OO0I00I0 <= O101lO0O;
            else
              OO0I00I0 <= 'X';
            end if;
          end if;
        else
          OO0I00I0 <= 'X';
        end if;

    end process;



    IO0OO1Ol        <= (others => 'X');

    sum           <= IO0OO1Ol when ((in_reg=0) AND (stages=1) AND (out_reg=0) AND (launch='0')) else IlIOI0ll;
    pipe_ovf      <= I1OOIO0I;
    pipe_full     <= III010ll;
    arrive        <= O0I100O1;
    arrive_id     <= ll010OOI;
    push_out_n    <= O0O101OO;
    pipe_census   <= O1l00O0I;


    
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
    
    if (num_inputs < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter num_inputs (lower bound: 1)"
        severity warning;
    end if;
    
    if (sum_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter sum_width (lower bound: 1)"
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

    
  OO0lO0OO  : process (clk) begin

    assert NOT (Is_X( clk ) AND (now > 0 ns)) 
      report "WARNING: Detected unknown value on the clock input port clk."
      severity warning;

  end process OO0lO0OO ;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

library dw03;

configuration DW_lp_piped_prod_sum_cfg_sim of DW_lp_piped_prod_sum is
 for sim
    for U1 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
 end for; -- sim
end DW_lp_piped_prod_sum_cfg_sim;
-- pragma translate_on
