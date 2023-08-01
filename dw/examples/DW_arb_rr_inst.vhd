library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_arb_rr_inst is
      generic (
	    inst_n : NATURAL := 4;
	    inst_output_mode : NATURAL := 1;
	    inst_index_mode : NATURAL := 0
	    );
      port (
	    inst_clk : in std_logic;
	    inst_rst_n : in std_logic;
	    inst_init_n : in std_logic;
	    inst_enable : in std_logic;
	    inst_request : in std_logic_vector(inst_n-1 downto 0);
	    inst_mask : in std_logic_vector(inst_n-1 downto 0);
	    granted_inst : out std_logic;
	    grant_inst : out std_logic_vector(inst_n-1 downto 0);
	    grant_index_inst : out std_logic_vector(bit_width(inst_n + (inst_index_mode mod 2))-1 downto 0)
	    );
    end DW_arb_rr_inst;


architecture inst of DW_arb_rr_inst is

begin

    -- Instance of DW_arb_rr
    U1 : DW_arb_rr
	generic map ( n => inst_n,
                output_mode => inst_output_mode,
                index_mode => inst_index_mode )
	port map ( clk => inst_clk,
                rst_n => inst_rst_n,
                init_n => inst_init_n,
                enable => inst_enable,
                request => inst_request,
                mask => inst_mask,
                granted => granted_inst,
                grant => grant_inst,
                grant_index => grant_index_inst );


end inst;
