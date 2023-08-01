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
-- AUTHOR:    Doug Lee    Jan. 18, 2008
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 7086ec7a
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Low Power Pipelined Multiplier Simulation Model
--
--           This receives two operands that get multiplied.  Configurable
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
--  a           M bits    Input      Multiplier
--  b           N bits    Input      Multipicand
--  product     P bits    Output     Product a x b
--
--  launch      1 bit     Input      Active High Control input to launch data into pipe
--  launch_id   Q bits    Input      ID tag for operation being launched
--  pipe_full   1 bit     Output     Status Flag indicating no slot for new launch
--  pipe_ovf    1 bit     Output     Status Flag indicating pipe overflow
--
--  accept_n    1 bit     Input      Flow Control Input, Active Low
--  arrive      1 bit     Output     Product available output
--  arrive_id   Q bits    Output     ID tag for product that has arrived
--  push_out_n  1 bit     Output     Active Low Output used with FIFO
--  pipe_census R bits    Output     Output bus indicating the number
--                                   of pipeline register levels currently occupied
--
--     Note: M is the value of "a_width" parameter
--     Note: N is the value of "b_width" parameter
--     Note: P is the value of "a_width + b_width"
--     Note: Q is the value of "id_width" parameter
--     Note: R is equal to the larger of '1' or ceil(log2(in_reg+stages+out_reg))
--
--
--  Modified:
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_lp_piped_mult is
	
-- pragma translate_off


  function O011001I( in_reg, stages, out_reg : in INTEGER ) return INTEGER is
    begin
        if((in_reg+(stages-1)+out_reg) >= 1) then
          return (in_reg+(stages-1)+out_reg);
        else
          return(1);
        end if;
  end O011001I; -- pipe_mgr stages

  constant l0011I01  : INTEGER := O011001I(in_reg, stages, out_reg);

  signal O01ll0OO              : std_logic_vector(a_width-1 downto 0);
  signal OIOl1O0O              : std_logic_vector(b_width-1 downto 0);
  signal Ill0Ol1O         : std_logic;
  signal O1OlOOlO      : std_logic_vector(id_width-1 downto 0);
  signal O11O00l0       : std_logic;

  signal IOO1I01O       : std_logic;
  signal OIO1O1l1        : std_logic;
  signal l0II01OO          : std_logic;
  signal Oll01I10       : std_logic_vector(id_width-1 downto 0);
  signal Il1000I0      : std_logic;
  signal OII00O00     : std_logic_vector(l0011I01-1 downto 0);
  signal OlO11O1l     : std_logic_vector(bit_width(l0011I01+1)-1 downto 0);

  signal OO11OIOO      : std_logic;
  signal I01OO110  : std_logic;
  signal I001I101       : std_logic;
  signal OI11IOO0         : std_logic;
  signal l11lO0lO      : std_logic_vector(id_width-1 downto 0);
  signal lI1O0I00     : std_logic;
  signal lO01OlI0    : std_logic_vector(l0011I01-1 downto 0);
  signal O0O10l0I    : std_logic_vector(bit_width(l0011I01+1)-1 downto 0);

  signal I0lIOOI1         : signed(a_width+b_width-1 downto 0);
  signal OOOO11Ol        : unsigned(a_width+b_width-1 downto 0);
  signal OlO1lOl0      : std_logic_vector(a_width+b_width-1 downto 0);
  signal Il110OO1     : std_logic_vector(a_width+b_width-1 downto 0);
  signal product_Xs         : std_logic_vector(a_width+b_width-1 downto 0);

  signal l010lO0I      : std_logic;
  signal OlOO11OO       : std_logic;
  signal Ol0O00OO         : std_logic;
  signal OO0II0IO      : std_logic_vector(id_width-1 downto 0);
  signal lI0I1l10     : std_logic;
  signal IIllO11l    : std_logic_vector(l0011I01-1 downto 0);
  signal l10l0011    : std_logic_vector(bit_width(l0011I01+1)-1 downto 0);


  constant IO1O0ll0 : integer := maximum(0, in_reg+stages+out_reg-2);
  constant word_of_Xs : std_logic_vector(a_width+b_width-1 downto 0) := (others => 'X');

  signal clk_int            : std_logic;
  signal rst_n_a            : std_logic;
  signal rst_n_s            : std_logic;
  type pipe_T is array (0 to IO1O0ll0) of std_logic_vector(a_width+b_width-1 downto 0);
  signal IOO00O11 : pipe_T;


-- pragma translate_on
begin
-- pragma translate_off

    clk_int <= To_X01(clk);
    rst_n_a <= rst_n WHEN (rst_mode = 0) ELSE '1';
    rst_n_s <= To_X01(rst_n);
    O01ll0OO <= To_X01(a);
    OIOl1O0O <= To_X01(b);
    Ill0Ol1O <= To_X01(launch);
    O1OlOOlO <= To_X01(launch_id);
    O11O00l0 <= To_X01(accept_n);

   
    OOOO11Ol   <= unsigned(O01ll0OO) * unsigned(OIOl1O0O);
    I0lIOOI1    <= signed(O01ll0OO) * signed(OIOl1O0O);
    OlO1lOl0 <= std_logic_vector(I0lIOOI1) when (tc_mode = 1) else std_logic_vector(OOOO11Ol);




  Il110OO1 <= OlO1lOl0 when ((in_reg+stages+out_reg) = 1) else IOO00O11(IO1O0ll0);



    U1 : DW_lp_pipe_mgr
        generic map (
          stages => l0011I01,
          id_width => id_width )
        port map (
          clk => clk_int,
          rst_n => rst_n_a,
          init_n => rst_n_s,
          launch => Ill0Ol1O,
          launch_id => O1OlOOlO,
          accept_n => O11O00l0,
          arrive => l0II01OO,
          arrive_id => Oll01I10,
          pipe_en_bus => OII00O00,
          pipe_full => IOO1I01O,
          pipe_ovf => OIO1O1l1,
          push_out_n => Il1000I0,
          pipe_census => OlO11O1l );


    OI11IOO0         <= Ill0Ol1O;
    l11lO0lO      <= O1OlOOlO;
    lO01OlI0    <= (others => '0');
    OO11OIOO      <= O11O00l0;
    I01OO110  <= OO11OIOO AND OI11IOO0;
    lI1O0I00     <= NOT(NOT(O11O00l0) AND Ill0Ol1O);
    O0O10l0I    <= (others => '0');
      
      
    Ol0O00OO       <= l0II01OO       when ((in_reg+stages+out_reg) > 1) else OI11IOO0;
    OO0II0IO    <= Oll01I10    when ((in_reg+stages+out_reg) > 1) else l11lO0lO;
    IIllO11l  <= OII00O00  when ((in_reg+stages+out_reg) > 1) else lO01OlI0;
    l010lO0I    <= IOO1I01O    when ((in_reg+stages+out_reg) > 1) else OO11OIOO;
    OlOO11OO     <= OIO1O1l1     when ((in_reg+stages+out_reg) > 1) else I001I101;
    lI0I1l10   <= Il1000I0   when ((in_reg+stages+out_reg) > 1) else lI1O0I00;
    l10l0011  <= OlO11O1l  when ((in_reg+stages+out_reg) > 1) else O0O10l0I;
    
    


    sim_clk: process (clk_int, rst_n_a)
      variable i  : INTEGER;
      begin

        if (rst_n_a = '0') then
          I001I101 <= '0';
        elsif (rst_n_a = '1') then
	  if (rising_edge(clk_int)) then
            if (rst_n_s = '0') then
              I001I101 <= '0';
            elsif (rst_n_s = '1') then
              I001I101 <= I01OO110;
            else
              I001I101 <= 'X';
            end if;
          end if;
        else
          I001I101 <= 'X';
	end if;

    end process;

    product_Xs    <= (others => 'X');

    product       <= product_Xs when ((in_reg=0) AND (stages=1) AND (out_reg=0) AND (launch='0')) else Il110OO1;
    pipe_ovf      <= OlOO11OO;
    pipe_full     <= l010lO0I;
    arrive        <= Ol0O00OO;
    arrive_id     <= OO0II0IO;
    push_out_n    <= lI0I1l10;
    pipe_census   <= l10l0011;


    
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

configuration DW_lp_piped_mult_cfg_sim of DW_lp_piped_mult is
 for sim
    for U1 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
 end for; -- sim
end DW_lp_piped_mult_cfg_sim;
-- pragma translate_on
