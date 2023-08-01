library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

-- example: functional inference of 4-input minimum/maximum component
entity DW_minmax_func is
  generic ( wordlength : natural := 8);
  port ( a0, a1, a2, a3 : in  std_logic_vector(wordlength-1 downto 0);
         tc             : in  std_logic;
         max            : in  std_logic;
         val            : out std_logic_vector(wordlength-1 downto 0) );
end DW_minmax_func;

architecture func of DW_minmax_func is
begin

  -- function calls for unsigned/signed minimum/maximum
  -- inputs are concatenated into the first function call operand "a"
  -- the second function call operand is "num_inputs"
  process (a0, a1, a2, a3, max, tc)
  begin
    if max = '0' then
      if tc = '0' then
        val <= std_logic_vector(DWF_min(unsigned(a3 & a2 & a1 & a0), 4));
      else
        val <= std_logic_vector(DWF_min(signed(a3 & a2 & a1 & a0), 4));
      end if;
    else
      if tc = '0' then
        val <= std_logic_vector(DWF_max(unsigned(a3 & a2 & a1 & a0), 4));
      else
        val <= std_logic_vector(DWF_max(signed(a3 & a2 & a1 & a0), 4));
      end if;      
    end if;
  end process;
 
end func;

