--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Rick Kelly        07/31/2000
--
-- VERSION:   VHDL Simulation Model for DW02_tree
--
-- DesignWare_version: 3ec04f44
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Wallace Tree Compressor
--
--             Aamir Farooqui 7/14/02
--             Corrected parameter checking, and X_processing
--------------------------------------------------------------------------------
--

library IEEE;
use IEEE.std_logic_1164.all;

architecture sim of DW02_tree is
	

-- pragma translate_off
    CONSTANT l0O001lI : INTEGER := num_inputs;
    CONSTANT IIl0O1II : INTEGER := input_width;
    SIGNAL   I0O0IIlO, OIO0lII1 : std_logic_vector(IIl0O1II-1 downto 0);
-- pragma translate_on
begin
-- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (num_inputs < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter num_inputs (lower bound: 1)"
        severity warning;
    end if;
    
    if (input_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter input_width (lower bound: 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
  
  l100I10I : process( INPUT )
    SUBTYPE  O0IO000l is std_logic_vector(IIl0O1II-1 downto 0);
    TYPE     II1lOOOO is array (0 to l0O001lI-1) of O0IO000l;
    variable lll0OIIO : II1lOOOO;
    variable O0ll0II0 : II1lOOOO;
    variable lIlO1lO0 : std_logic_vector(IIl0O1II-1 downto 0);
    variable lO0l1OOO : INTEGER;
    begin
      for OO1IOlll in 0 to l0O001lI-1 loop
        lll0OIIO(OO1IOlll) := INPUT(IIl0O1II*(OO1IOlll+1)-1 downto IIl0O1II*OO1IOlll);
      end loop;
      lO0l1OOO := l0O001lI;
      while (lO0l1OOO > 2) loop
        for OO1IOlll in 0 to (lO0l1OOO/3)-1 loop
          O0ll0II0(OO1IOlll*2) := lll0OIIO(OO1IOlll*3) XOR
                                lll0OIIO(OO1IOlll*3+1) XOR
                                lll0OIIO(OO1IOlll*3+2);
          lIlO1lO0 := (lll0OIIO(OO1IOlll*3) AND lll0OIIO(OO1IOlll*3+1)) OR
                          (lll0OIIO(OO1IOlll*3+1) AND lll0OIIO(OO1IOlll*3+2)) OR
                          (lll0OIIO(OO1IOlll*3) AND lll0OIIO(OO1IOlll*3+2));
          O0ll0II0(OO1IOlll*2+1) := lIlO1lO0(IIl0O1II-2 downto 0) & '0';
        end loop;
        if (lO0l1OOO mod 3) > 0 then
          for OO1IOlll in 0 to (lO0l1OOO mod 3)-1 loop
            O0ll0II0(2 * (lO0l1OOO/3) + OO1IOlll) := lll0OIIO(3 * (lO0l1OOO/3) + OO1IOlll);
          end loop;
        end if;
        lll0OIIO := O0ll0II0;
        lO0l1OOO := lO0l1OOO - (lO0l1OOO/3);
      end loop;

      I0O0IIlO <= lll0OIIO(0);

      if (lO0l1OOO = 1) then
        OIO0lII1 <= (others => '0');
      else
        OIO0lII1 <= lll0OIIO(1);
      end if;

    end process l100I10I;

    OUT0 <= (others => 'X') when (Is_X(INPUT)) else I0O0IIlO;
    OUT1 <= (others => 'X') when (Is_X(INPUT)) else OIO0lII1;

-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW02_tree_cfg_sim of DW02_tree is
 for sim
 end for; -- sim
end DW02_tree_cfg_sim;
-- pragma translate_on
