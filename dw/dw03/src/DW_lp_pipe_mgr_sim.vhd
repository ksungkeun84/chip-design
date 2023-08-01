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
-- AUTHOR:    Doug Lee    Feb. 22, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 29db1a89
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
--
--  ABSTRACT: Pipeline Manager Simulation Model
--
--       This component tracks the activity in the pipeline
--       throttled by 'launch' and 'accept_n' inputs.  Active
--       launched transactions are allowed to fill the pipeline
--       when the downstream logic is not accepting new arrivals.
--
--  Parameters:     Valid Range    Default Value
--  ==========      ===========    =============
--  stages          1 to 1023          2
--  id_width        1 to 1024          2
--
--
--  Ports       Size    Direction    Description
--  =====       ====    =========    ===========
--  clk         1 bit     Input      Clock Input
--  rst_n       1 bit     Input      Async. Reset Input, Active Low
--  init_n      1 bit     Input      Sync. Reset Input, Active Low
--
--  launch      1 bit     Input      Active High Control input to lauche data into pipe
--  launch_id  id_width   Input      ID tag for data being launched (optional)
--  pipe_full   1 bit     Output     Status Flag indicating no slot for new data
--  pipe_ovf    1 bit     Output     Status Flag indicating pipe overflow
--
--  pipe_en_bus stages    Output     Bus of enables (one per pipe stage), Active High
--
--  accept_n    1 bit     Input      Flow Control Input, Active Low
--  arrive      1 bit     Output     Data Available output
--  arrive_id  id_width   Output     ID tag for data that's arrived (optional)
--  push_out_n  1 bit     Output     Active Low Output used with FIFO (optional)
--  pipe_census M bits    Output     Output bus indicating the number
--                                   of pipe stages currently occupied
--
--    Note: The value of M is equal to the ceil(log2(stages+1)).
--
--
-- MODIFIED:
--     DLL   9-13-07  Changed name from DW_pipe_mgr
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use STD.textio.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp_arith.all;

architecture sim of DW_lp_pipe_mgr is
	
-- pragma translate_off

  type FifoArrayType is array (0 to stages-1) of
         std_logic_vector(id_width-1 downto 0);

  signal I011l111         : FifoArrayType;

  signal I0OOlIOO          : std_logic;
  signal I1OO1OO1        : std_logic;
  signal O0OII00O       : std_logic;
  signal IIllO1l0       : std_logic;
  signal I1l0001O    : std_logic_vector(id_width-1 downto 0);
  signal ll1I1II0     : std_logic;

  signal lO0O1llI             : std_logic_vector(stages-1 downto 0);
  signal IOO1O1O1        : std_logic_vector(stages-1 downto 0);

  signal lOlI1111           : std_logic_vector(stages-1 downto 0);
  signal O1101011  : std_logic_vector(stages-1 downto 0);
  signal pipe_full_int    : std_logic;
  signal l0IO0111     : std_logic;
  signal OOIl0IO0           : std_logic;
  signal O0l10O00  : std_logic_vector(bit_width(stages+1)-1 downto 0);

-- pragma translate_on
begin
-- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (stages < 1) OR (stages > 1023) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter stages (legal range: 1 to 1023)"
        severity warning;
    end if;
    
    if (id_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter id_width (lower bound: 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    I0OOlIOO <= To_X01(clk);
    I1OO1OO1 <= To_X01(rst_n);
    O0OII00O <= To_X01(init_n);
    IIllO1l0 <= To_X01(launch);
    I1l0001O <= To_X01(launch_id);
    ll1I1II0 <= To_X01(accept_n);

    OOIl0IO0 <= NOT(ll1I1II0); 

    I010IOI1: process (lOlI1111, lO0O1llI, OOIl0IO0)
      variable I111IOO0  : INTEGER;
      begin
	for I111IOO0 in stages-1 downto 0 loop
          if (I111IOO0 = stages-1) then
            lOlI1111(I111IOO0) <= OOIl0IO0 OR NOT(lO0O1llI(I111IOO0));
          else
            lOlI1111(I111IOO0) <= lOlI1111(I111IOO0+1) OR NOT(lO0O1llI(I111IOO0));
          end if; 
	end loop;
    end process;  -- I010IOI1


    OOll0001: process (lOlI1111, lO0O1llI, IIllO1l0)
      variable I111IOO0  : INTEGER;
      begin
        for I111IOO0 in 0 to stages-1 loop
          if(I111IOO0 = 0) then
            if (lOlI1111(0) = '1') then
              IOO1O1O1(0) <= IIllO1l0;
            else
              IOO1O1O1(0) <= lO0O1llI(0);
            end if;
          else
            if (lOlI1111(I111IOO0) = '1') then
              IOO1O1O1(I111IOO0) <= lO0O1llI(I111IOO0-1);
            else
              IOO1O1O1(I111IOO0) <= lO0O1llI(I111IOO0);
            end if;
          end if;
        end loop;
    end process; -- OOll0001

    O01100OO: process (lOlI1111, IOO1O1O1)
      variable I111IOO0  : INTEGER;
      begin
        for I111IOO0 in 0 to stages-1 loop
          O1101011(I111IOO0) <= lOlI1111(I111IOO0) AND IOO1O1O1(I111IOO0);
        end loop;
    end process;  -- O01100OO

    Oll1OII0: process (lO0O1llI)
      variable cnt : INTEGER;
      variable I111IOO0   : INTEGER;
      begin
	cnt := 0;
        for I111IOO0 in 0 to stages-1 loop
	  if (lO0O1llI(I111IOO0) = '1') then
            cnt := cnt + 1;
          elsif (lO0O1llI(I111IOO0) = 'X') then
            cnt := -1;
	  end if;
        end loop;
        
        if (cnt = -1) then
          O0l10O00 <= (others => 'X');
        else
          O0l10O00 <= CONV_STD_LOGIC_VECTOR(cnt, bit_width(stages+1));
        end if;
    end process;  -- Oll1OII0


    sim_clk: process (I0OOlIOO, I1OO1OO1)
      variable I111IOO0  : INTEGER;
      begin

        if (I1OO1OO1 = '0') then
          lO0O1llI     <= (others => '0');
          l0IO0111 <= '0';
	  for I111IOO0 in 0 to (stages-1) loop
            I011l111(I111IOO0) <= (others => '0');
	  end loop;
        elsif (I1OO1OO1 = '1') then
	  if (rising_edge(I0OOlIOO)) then
	    if (O0OII00O = '0') then
              lO0O1llI     <= (others => '0');
              l0IO0111 <= '0';
	      for I111IOO0 in 0 to (stages-1) loop
                I011l111(I111IOO0) <= (others => '0');
	      end loop;
	    elsif (O0OII00O = '1') then
              lO0O1llI     <= IOO1O1O1;
              l0IO0111 <= NOT(lOlI1111(0)) AND IIllO1l0;
	      for I111IOO0 in 0 to (stages-1) loop
                if (I111IOO0 = 0) then
                  if ((lOlI1111(0) = '1') AND (IIllO1l0 = '1')) then
                    I011l111(0) <= I1l0001O;
                  end if;
                else
                  if ((lOlI1111(I111IOO0) = '1') AND (IOO1O1O1(I111IOO0) = '1')) then
                    I011l111(I111IOO0) <= I011l111(I111IOO0-1);
                  end if;
                end if;
	      end loop;
            else
              lO0O1llI     <= (others => 'X');
              l0IO0111 <= 'X';
	      for I111IOO0 in 0 to (stages-1) loop
                I011l111(I111IOO0) <= (others => 'X');
	      end loop;
	    end if;
          else
            lO0O1llI     <= lO0O1llI;
            l0IO0111 <= l0IO0111;
	    for I111IOO0 in 0 to (stages-1) loop
              I011l111(I111IOO0) <= I011l111(I111IOO0);
	    end loop;
	  end if;
	else
          lO0O1llI     <= (others => 'X');
          l0IO0111 <= 'X';
	  for I111IOO0 in 0 to (stages-1) loop
            I011l111(I111IOO0) <= (others => 'X');
	  end loop;
	end if;

    end process;

    pipe_en_bus   <= O1101011;
    pipe_ovf      <= l0IO0111;
    pipe_full     <= AND_REDUCE(lO0O1llI) AND NOT(OOIl0IO0);
    arrive        <= lO0O1llI(stages-1);
    arrive_id     <= I011l111(stages-1);
    push_out_n    <= NOT(OOIl0IO0 AND lO0O1llI(stages-1));
    pipe_census   <= O0l10O00;

    
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

configuration DW_lp_pipe_mgr_cfg_sim of DW_lp_pipe_mgr is
 for sim
 end for; -- sim
end DW_lp_pipe_mgr_cfg_sim;
-- pragma translate_on
