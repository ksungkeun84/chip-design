library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation.all;
-- If using numeric_std data types of std_logic_arith, uncomment the 
-- following line:
-- use DWARE.DW_Foundation_arith.all;

entity DW_lod_func is
      generic (
	    func_a_width : POSITIVE := 8
	    );
      port (
	    func_a : in std_logic_vector(func_a_width-1 downto 0);
	    dec_func : out std_logic_vector(func_a_width-1 downto 0);
	    enc_func : out std_logic_vector(bit_width(func_a_width) downto 0)
	    );
    end DW_lod_func;

architecture func of DW_lod_func is
begin

    -- Inferred function of DW_lod
    dec_func <= DWF_lod(func_a);
    enc_func <= DWF_lod_enc(func_a);

end func;

-- pragma translate_off
configuration DW_lod_func_cfg_func of DW_lod_func is
for func
end for; -- func
end DW_lod_func_cfg_func;
-- pragma translate_on


