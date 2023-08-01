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
-- DesignWare_version: ab40594d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
-- ABSTRACT: Low Power Pipelined Divider Simulation Model
--
--           This receives two operands that get divided.  Configurable
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
--   faithful_round    0 to 1       select the faithful_rounding that admits 1 ulp error
--                                  0 - default value. it keeps all rounding modes
--                                  1 - z has 1 ulp error. RND input does not affect
--                                  the output
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
--     RJK  09/06/18  Release last update of the VHDL sim model (STAR 9001396240)
--
--     LMSU 02/17/15  Updated to eliminate derived internal clock and reset signals
--
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

architecture sim of DW_lp_piped_fp_div is
	
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

signal lOOO001I              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal O1I10OOO              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal l1l1I1O0            : std_logic_vector(2 downto 0);
signal I1lI010O         : std_logic;
signal I1110110      : std_logic_vector(id_width-1 downto 0);
signal OlOO0lO0       : std_logic;

signal I0I011IO              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal l111O0OI              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal l1I10O00            : std_logic_vector(2 downto 0);
signal O1O110OO              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal l10lO001              : std_logic_vector((sig_width + exp_width + 1)-1 downto 0);
signal O0O0OIlI            : std_logic_vector(2 downto 0);

signal l0111O1I       : std_logic;
signal O0001l0I        : std_logic;
signal l1OOIl1l          : std_logic;
signal O1OO100l       : std_logic_vector(id_width-1 downto 0);
signal IOO1OII1    : std_logic_vector(id_width-1 downto 0);
signal l10l1O1I      : std_logic;
signal IlO0I10l     : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal O1ll10O0     : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);

signal l01llO01      : std_logic;
signal llOlI1O1  : std_logic;
signal OO01001O       : std_logic;
signal IOl11OlO         : std_logic;
signal O1I1O011      : std_logic_vector(id_width-1 downto 0);
signal OIO100OO     : std_logic;
signal OlO0lOOO    : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal O0IlO0l1    : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);

signal O0III0l0            : std_logic_vector((sig_width + exp_width )+8 downto 0);
signal OlI011ll           : std_logic_vector((sig_width + exp_width )+8 downto 0);
signal pl_pipe_in_data    : std_logic_vector((sig_width + exp_width )+8 downto 0);
signal pl_input_reg       : std_logic_vector((sig_width + exp_width )+8 downto 0);
signal pl_output_reg      : std_logic_vector((sig_width + exp_width )+8 downto 0);

signal OI1011Ol              : std_logic_vector(sig_width + exp_width  downto 0);
signal lOOOIOlO         : std_logic_vector(7 downto 0);

signal pipe_full_int      : std_logic;
signal pipe_ovf_int       : std_logic;
signal arrive_int         : std_logic;
signal arrive_id_int      : std_logic_vector(id_width-1 downto 0);
signal push_out_n_int     : std_logic;
signal O11IO1lI    : std_logic_vector(pipe_mgr_stages-1 downto 0);
signal pipe_census_int    : std_logic_vector(bit_width(pipe_mgr_stages+1)-1 downto 0);


constant out_en_bus_width : integer := maximum(1, stages-1+out_reg);

signal pipe_en_in_bus_int : std_logic;
signal OlIO1IO0         : std_logic_vector(out_en_bus_width-1 downto 0);

constant pl_id_reg_en_msb  : integer := maximum(0, in_reg+stages+out_reg-2);
constant pl_reg_en_msb : integer := maximum(0, in_reg+stages+out_reg-2);
constant pl_reg_width  : integer := (sig_width + exp_width + 1)  +8;
constant word_of_Xs : std_logic_vector((sig_width + exp_width + 1)-1 downto 0) := (others => 'X');
constant word_of_Xs_id              : std_logic_vector(id_width-1 downto 0) := (others => 'X');

type   pipe_T    is array (0 to stages-1) of std_logic_vector(pl_reg_width-1 downto 0);
type   pipe_id_T is array (0 to pl_id_reg_en_msb) of std_logic_vector(id_width-1 downto 0);
signal OOIOIIOO            : pipe_T;
signal pl_regs_id         : pipe_id_T;


-- pragma translate_on
begin
-- pragma translate_off

  lOOO001I     <= To_X01(a);
  O1I10OOO     <= To_X01(b);
  l1l1I1O0   <= To_X01(rnd);
  
  I1lI010O    <= To_X01(launch);
  I1110110 <= To_X01(launch_id);
  OlOO0lO0  <= To_X01(accept_n);
  
DW_Il0O00OO: if rst_mode=0 generate
  DW_l10OlOO0 : process (clk, rst_n) begin
    if (rst_n = '0') then
      I0I011IO   <= (others => '0');
      l111O0OI   <= (others => '0');
      l1I10O00 <= (others => '0');
    elsif (rst_n = '1') then
      if (rising_edge(clk)) then
        if (O11IO1lI(0) = '1') then
          I0I011IO   <= lOOO001I;
          l111O0OI   <= O1I10OOO;
          l1I10O00 <= l1l1I1O0;
        end if;
      end if;
    else
      I0I011IO   <= (others => 'X');
      l111O0OI   <= (others => 'X');
      l1I10O00 <= (others => 'X');
    end if;
  end process DW_l10OlOO0;
end generate;

DW_lO0l011l: if rst_mode=1 generate
  DW_l10OlOO0 : process (clk) begin
    if (rising_edge(clk)) then
      if (rst_n = '0') then
        I0I011IO   <= (others => '0');
        l111O0OI   <= (others => '0');
        l1I10O00 <= (others => '0');
      elsif (rst_n = '1') then
        if (O11IO1lI(0) = '1') then
          I0I011IO   <= lOOO001I;
          l111O0OI   <= O1I10OOO;
          l1I10O00 <= l1l1I1O0;
        end if;
      else
        I0I011IO   <= (others => 'X');
        l111O0OI   <= (others => 'X');
        l1I10O00 <= (others => 'X');
      end if;
    end if;
  end process DW_l10OlOO0;
end generate;

O1O110OO   <= lOOO001I   when (in_reg=0) else   I0I011IO;
l10lO001   <= O1I10OOO   when (in_reg=0) else   l111O0OI;
O0O0OIlI <= l1l1I1O0 when (in_reg=0) else l1I10O00;


GEN_PL_REGS_ID_RM_EQ_0: if rst_mode=0 generate


  PROC_pl_registers_id : process (clk, rst_n) begin
    if ((in_reg+stages+out_reg) > 1) then
      if (rst_n = '0') then
	for OlO1O0OO in 0 to pl_reg_en_msb loop
	  pl_regs_id(OlO1O0OO) <= (others => '0');
	end loop;
      elsif (rst_n = '1') then
	if (rising_edge(clk)) then
	  for OlO1O0OO in 0 to pl_reg_en_msb loop
	    if (OlO1O0OO = 0) then
	      if (O11IO1lI(OlO1O0OO) = '1') then
		pl_regs_id(OlO1O0OO) <= I1110110;
	      elsif (O11IO1lI(OlO1O0OO) /= '0') then
		pl_regs_id(OlO1O0OO) <= ((pl_regs_id(OlO1O0OO) XOR I1110110)
				  AND word_of_Xs_id) XOR pl_regs_id(OlO1O0OO);
	      end if;
	    else
	      if (O11IO1lI(OlO1O0OO) = '1') then
		pl_regs_id(OlO1O0OO) <= pl_regs_id(OlO1O0OO-1);
	      elsif (O11IO1lI(OlO1O0OO) /= '0') then
		pl_regs_id(OlO1O0OO) <= ((pl_regs_id(OlO1O0OO) XOR pl_regs_id(OlO1O0OO-1))
				    AND word_of_Xs_id) XOR pl_regs_id(OlO1O0OO);
	      end if;
	    end if;
	  end loop;
  	end if;
      else
	for OlO1O0OO in 0 to pl_reg_en_msb loop
	  pl_regs_id(OlO1O0OO) <= (others => 'X');
	end loop;
      end if;
    end if;
  end process PROC_pl_registers_id;

  IOO1OII1 <= I1110110 when ((in_reg+stages+out_reg) = 1) else pl_regs_id(pl_reg_en_msb);


end generate;

GEN_PL_REGS_ID_RM_EQ_1: if rst_mode=1 generate


  PROC_pl_registers_id : process (clk) begin
    if ((in_reg+stages+out_reg) > 1) then
      if (rising_edge(clk)) then
	if (rst_n = '0') then
	  for OlO1O0OO in 0 to pl_reg_en_msb loop
	    pl_regs_id(OlO1O0OO) <= (others => '0');
	  end loop;
	elsif (rst_n = '1') then
	  for OlO1O0OO in 0 to pl_reg_en_msb loop
	    if (OlO1O0OO = 0) then
	      if (O11IO1lI(OlO1O0OO) = '1') then
		pl_regs_id(OlO1O0OO) <= I1110110;
	      elsif (O11IO1lI(OlO1O0OO) /= '0') then
		pl_regs_id(OlO1O0OO) <= ((pl_regs_id(OlO1O0OO) XOR I1110110)
				  AND word_of_Xs_id) XOR pl_regs_id(OlO1O0OO);
	      end if;
	    else
	      if (O11IO1lI(OlO1O0OO) = '1') then
		pl_regs_id(OlO1O0OO) <= pl_regs_id(OlO1O0OO-1);
	      elsif (O11IO1lI(OlO1O0OO) /= '0') then
		pl_regs_id(OlO1O0OO) <= ((pl_regs_id(OlO1O0OO) XOR pl_regs_id(OlO1O0OO-1))
				    AND word_of_Xs_id) XOR pl_regs_id(OlO1O0OO);
	      end if;
	    end if;
	  end loop;
	else
	  for OlO1O0OO in 0 to pl_reg_en_msb loop
	    pl_regs_id(OlO1O0OO) <= (others => 'X');
	  end loop;
	end if;
      end if;
    end if;
  end process PROC_pl_registers_id;

  IOO1OII1 <= I1110110 when ((in_reg+stages+out_reg) = 1) else pl_regs_id(pl_reg_en_msb);


end generate;

  -- Instance of DW_fp_div
  U1 : DW_fp_div
	generic map (
		sig_width => sig_width,
		exp_width => exp_width,
		ieee_compliance => ieee_compliance,
		faithful_round => faithful_round
		)
	port map (
		a => O1O110OO,
		b => l10lO001,
		rnd => O0O0OIlI,
		z => OI1011Ol,
		status => lOOOIOlO
		);

  O0III0l0 <= (OI1011Ol & (lOOOIOlO XOR "00000001"));
 


GEN_PL_REGS_RM_EQ_0: if rst_mode=0 generate



  pl_pipe_in_data <= O0III0l0 when (1-1 = 0) else pl_input_reg;
  OOIOIIOO(0) <= pl_pipe_in_data;

  PROC_registers : process (clk, rst_n) begin
    OOIOIIOO(0) <= (others => 'Z');
    if ((in_reg+stages+out_reg) > 1) then
      if (rst_n = '0') then
        pl_input_reg <= (others => '0');
        for OlO1O0OO in 1 to stages-1 loop
          OOIOIIOO(OlO1O0OO) <= (others => '0');
        end loop;
        pl_output_reg <= (others => '0');
      elsif (rst_n = '1') then
        if (rising_edge(clk)) then
          if (OlIO1IO0(0) = '1') then
            pl_input_reg <= O0III0l0;
          end if;
          for OlO1O0OO in 1 to stages-1 loop
            if (OlIO1IO0(OlO1O0OO-1+1-1) = '1') then
              OOIOIIOO(OlO1O0OO) <= OOIOIIOO(OlO1O0OO-1);
            end if;
          end loop;
          if (OlIO1IO0(pl_reg_en_msb-in_reg) = '1') then
            pl_output_reg <= OOIOIIOO(stages-1);
          end if;
        end if;
      else
        pl_input_reg <= (others => 'X');
        for OlO1O0OO in 1 to stages-1 loop
          OOIOIIOO(OlO1O0OO) <= (others => 'X');
        end loop;
        pl_output_reg <= (others => 'X');
      end if;
    end if;
  end process PROC_registers;

  OlI011ll <=    O0III0l0 when ((in_reg+stages+out_reg) = 1) else
                  pl_output_reg when                (out_reg = 1) else
                  OOIOIIOO(stages-1);



end generate;

GEN_PL_REGS_RM_EQ_1: if rst_mode=1 generate




  pl_pipe_in_data <= O0III0l0 when (1-1 = 0) else pl_input_reg;
  OOIOIIOO(0) <= pl_pipe_in_data;

  PROC_registers : process (clk) begin
    OOIOIIOO(0) <= (others => 'Z');
    if ((in_reg+stages+out_reg) > 1) then
      if (rising_edge(clk)) then
        if (rst_n = '0') then
          pl_input_reg <= (others => '0');
          for OlO1O0OO in 1 to stages-1 loop
            OOIOIIOO(OlO1O0OO) <= (others => '0');
          end loop;
          pl_output_reg <= (others => '0');
        elsif (rst_n = '1') then
          if (OlIO1IO0(0) = '1') then
            pl_input_reg <= O0III0l0;
          end if;
          for OlO1O0OO in 1 to stages-1 loop
            if (OlIO1IO0(OlO1O0OO-1+1-1) = '1') then
              OOIOIIOO(OlO1O0OO) <= OOIOIIOO(OlO1O0OO-1);
            end if;
          end loop;
          if (OlIO1IO0(pl_reg_en_msb-in_reg) = '1') then
            pl_output_reg <= OOIOIIOO(stages-1);
          end if;
        else
          pl_input_reg <= (others => 'X');
          for OlO1O0OO in 1 to stages-1 loop
            OOIOIIOO(OlO1O0OO) <= (others => 'X');
          end loop;
          pl_output_reg <= (others => 'X');
        end if;
      end if;
    end if;
  end process PROC_registers;

  OlI011ll <=    O0III0l0 when ((in_reg+stages+out_reg) = 1) else
                  pl_output_reg when                (out_reg = 1) else
                  OOIOIIOO(stages-1);


end generate;


GEN_INSTANCE_RM_EQ_0: if rst_mode=0 generate
  U1 : DW_lp_pipe_mgr
      generic map (
        stages => pipe_mgr_stages,
        id_width => id_width )
      port map (
        clk => clk,
        rst_n => rst_n,
        init_n => '1',
        launch => I1lI010O,
        launch_id => I1110110,
        accept_n => OlOO0lO0,
        arrive => l1OOIl1l,
        arrive_id => O1OO100l,
        pipe_en_bus => IlO0I10l,
        pipe_full => l0111O1I,
        pipe_ovf => O0001l0I,
        push_out_n => l10l1O1I,
        pipe_census => O1ll10O0 );

  sim_clk: process (clk, rst_n)
    variable OlO1O0OO  : INTEGER;
    begin
      if (rst_n = '0') then
        OO01001O <= '0';
      elsif (rst_n = '1') then
	if (rising_edge(clk)) then
          OO01001O <= llOlI1O1;
        end if;
      else
        OO01001O <= 'X';
	end if;
  end process;
end generate;

GEN_INSTANCE_RM_EQ_1: if rst_mode=1 generate
  U1 : DW_lp_pipe_mgr
      generic map (
        stages => pipe_mgr_stages,
        id_width => id_width )
      port map (
        clk => clk,
        rst_n => '1',
        init_n => rst_n,
        launch => I1lI010O,
        launch_id => I1110110,
        accept_n => OlOO0lO0,
        arrive => l1OOIl1l,
        arrive_id => O1OO100l,
        pipe_en_bus => IlO0I10l,
        pipe_full => l0111O1I,
        pipe_ovf => O0001l0I,
        push_out_n => l10l1O1I,
        pipe_census => O1ll10O0 );

  sim_clk: process (clk)
    variable OlO1O0OO  : INTEGER;
    begin
      if (rising_edge(clk)) then
        if (rst_n = '0') then
          OO01001O <= '0';
        elsif (rst_n = '1') then
          OO01001O <= llOlI1O1;
        else
          OO01001O <= 'X';
        end if;
      end if;
  end process;
end generate;


  IOl11OlO         <= I1lI010O;
  O1I1O011      <= I1110110;
  OlO0lOOO    <= (others => '0');
  l01llO01      <= OlOO0lO0;
  llOlI1O1  <= l01llO01 AND IOl11OlO;
  OIO100OO     <= NOT(NOT(OlOO0lO0) AND I1lI010O);
  O0IlO0l1    <= (others => '0');
    
  pipe_ctrl_out_int1: process (l1OOIl1l, l0111O1I, O0001l0I, l10l1O1I, O1ll10O0,
                               IOl11OlO, l01llO01, OO01001O, OIO100OO, O0IlO0l1)
    begin
      if (no_pm=1) then
         arrive_int       <= '0';
         pipe_full_int    <= '0';
         pipe_ovf_int     <= '0';
         push_out_n_int   <= '0';
         pipe_census_int  <= (others => '0'); 
      else
         if ((in_reg+stages+out_reg) > 1) then
           arrive_int       <= l1OOIl1l;
           pipe_full_int    <= l0111O1I;
           pipe_ovf_int     <= O0001l0I;
           push_out_n_int   <= l10l1O1I;
           pipe_census_int  <= O1ll10O0;
         else
           arrive_int       <= IOl11OlO;
           pipe_full_int    <= l01llO01;
           pipe_ovf_int     <= OO01001O;
           push_out_n_int   <= OIO100OO;
           pipe_census_int  <= O0IlO0l1;
         end if;
      end if;
  end process pipe_ctrl_out_int1;

  pipe_ctrl_out_int2: process (IOO1OII1, O1OO100l, IlO0I10l,
                               O1I1O011, OlO0lOOO, launch)
    begin
      if ((in_reg+stages+out_reg) > 1) then
        if (no_pm=1) then
          arrive_id_int    <= IOO1OII1;
          O11IO1lI  <= (others => launch);
        else
          arrive_id_int    <= O1OO100l;
          O11IO1lI  <= IlO0I10l;
        end if;
      else
        arrive_id_int    <= O1I1O011;
        O11IO1lI  <= OlO0lOOO;
      end if;
  end process pipe_ctrl_out_int2;


  pipe_en_in_bus_int <= O11IO1lI(0);

  pipe_out_en_bus_PROC: process (O11IO1lI)
    begin
      if (in_reg = 1) then
        OlIO1IO0(0) <= '0';
        for OlO1O0OO in 1 to pipe_mgr_stages-1 loop
          OlIO1IO0(OlO1O0OO-1) <= O11IO1lI(OlO1O0OO);
        end loop;
      else
        OlIO1IO0 <= O11IO1lI;
      end if;
  end process pipe_out_en_bus_PROC;


  z           <= OlI011ll((sig_width + exp_width +8) downto 8);
  status      <= OlI011ll(7 downto 0) XOR "00000001";
  
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
  
    if ( (faithful_round < 0) OR (faithful_round > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter faithful_round (legal range: 0 to 1)"
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

-- pragma translate_off
library dw02, dw03;

configuration DW_lp_piped_fp_div_cfg_sim of DW_lp_piped_fp_div is
  for sim
    for U1 : DW_fp_div use configuration dw02.DW_fp_div_cfg_sim; end for;
    for GEN_INSTANCE_RM_EQ_0
      for U1 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
    end for; -- GEN_INSTANCE_RM_EQ_0
    for GEN_INSTANCE_RM_EQ_1
      for U1 : DW_lp_pipe_mgr use configuration dw03.DW_lp_pipe_mgr_cfg_sim; end for;
    end for; -- GEN_INSTANCE_RM_EQ_1
  end for; -- sim
end DW_lp_piped_fp_div_cfg_sim;
-- pragma translate_on
