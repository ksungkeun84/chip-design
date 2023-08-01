library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_arith.all;

entity DW_rbsh_func is
      generic (
	    func_A_width : POSITIVE := 8;
	    func_SH_width : POSITIVE := 3
	    );
      port (
	    func_A : in std_logic_vector(func_A_width-1 downto 0);
	    func_SH : in std_logic_vector(func_SH_width-1 downto 0);
	    func_SH_TC : in std_logic;
	    B_func : out std_logic_vector(func_A_width-1 downto 0)
	    );
    end DW_rbsh_func;


architecture func of DW_rbsh_func is

begin

    -- Functional inference of DW_rbsh
    B_func <= std_logic_vector(DWF_rbsh(UNSIGNED(func_A),UNSIGNED(func_SH)));

end func;

