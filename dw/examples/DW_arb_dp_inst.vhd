library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.dw_foundation_comp.all;

entity DW_arb_dp_inst is
      generic (
	    inst_n : NATURAL := 4;
	    inst_park_mode : NATURAL := 1;
	    inst_park_index : NATURAL := 0;
	    inst_output_mode : NATURAL := 1
	    );
      port (
	    inst_clk : in std_logic;
	    inst_rst_n : in std_logic;
	    inst_init_n : in std_logic;
	    inst_enable : in std_logic;
	    inst_request : in std_logic_vector(inst_n-1 downto 0);
	  inst_prior : in std_logic_vector(bit_width(inst_n)*inst_n-1 downto 0);
	    inst_lock : in std_logic_vector(inst_n-1 downto 0);
	    inst_mask : in std_logic_vector(inst_n-1 downto 0);
	    parked_inst : out std_logic;
	    granted_inst : out std_logic;
	    locked_inst : out std_logic;
	    grant_inst : out std_logic_vector(inst_n-1 downto 0);
	   grant_index_inst : out std_logic_vector(bit_width(inst_n)-1 downto 0)
	    );
    end DW_arb_dp_inst;


architecture inst of DW_arb_dp_inst is

begin

    -- Instance of DW_arb_dp
    U1 : DW_arb_dp
	generic map (
		n => inst_n,
		park_mode => inst_park_mode,
		park_index => inst_park_index,
		output_mode => inst_output_mode
		)
	port map (
		clk => inst_clk,
		rst_n => inst_rst_n,
		init_n => inst_init_n,
		enable => inst_enable,
		request => inst_request,
		prior => inst_prior,
		lock => inst_lock,
		mask => inst_mask,
		parked => parked_inst,
		granted => granted_inst,
		locked => locked_inst,
		grant => grant_inst,
		grant_index => grant_index_inst
		);


end inst;

-- pragma translate_off
configuration DW_arb_dp_inst_cfg_inst of DW_arb_dp_inst is
  for inst
  end for; -- inst
end DW_arb_dp_inst_cfg_inst;
-- pragma translate_on
