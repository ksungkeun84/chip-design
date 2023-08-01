library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_tap_inst is
      generic (
	    inst_width : INTEGER := 8;
	    inst_id : INTEGER := 0;
	    inst_version : INTEGER := 0;
	    inst_part : INTEGER := 0;
	    inst_man_num : INTEGER := 0;
	    inst_sync_mode : INTEGER := 0;
	    inst_tst_mode : INTEGER := 1
	    );
      port (
	    inst_tck : in std_logic;
	    inst_trst_n : in std_logic;
	    inst_tms : in std_logic;
	    inst_tdi : in std_logic;
	    inst_so : in std_logic;
	    inst_bypass_sel : in std_logic;
	    inst_sentinel_val : in std_logic_vector(inst_width-2 downto 0);
	    clock_dr_inst : out std_logic;
	    shift_dr_inst : out std_logic;
	    update_dr_inst : out std_logic;
	    tdo_inst : out std_logic;
	    tdo_en_inst : out std_logic;
	    tap_state_inst : out std_logic_vector(15 downto 0);
	    extest_inst : out std_logic;
	    samp_load_inst : out std_logic;
	    instructions_inst : out std_logic_vector(inst_width-1 downto 0);
	    sync_capture_en_inst : out std_logic;
	    sync_update_dr_inst : out std_logic;
	    inst_test : in std_logic
	    );
    end DW_tap_inst;


architecture inst of DW_tap_inst is

begin

    -- Instance of DW_tap
    U1 : DW_tap
	generic map ( width => inst_width,
                      id => inst_id,
                      version => inst_version,
                      part => inst_part,
                      man_num => inst_man_num,
                      sync_mode => inst_sync_mode,
                      tst_mode => inst_tst_mode )
	port map (  tck => inst_tck,
	            trst_n => inst_trst_n,
	            tms => inst_tms,
	            tdi => inst_tdi,
	            so => inst_so,
	            bypass_sel => inst_bypass_sel,
	            sentinel_val => inst_sentinel_val,
	            clock_dr => clock_dr_inst,
	            shift_dr => shift_dr_inst,
	            update_dr => update_dr_inst,
	            tdo => tdo_inst,
	            tdo_en => tdo_en_inst,
	            tap_state => tap_state_inst,
	            extest => extest_inst,
	            samp_load => samp_load_inst,
	            instructions => instructions_inst,
	            sync_capture_en => sync_capture_en_inst,
	            sync_update_dr => sync_update_dr_inst,
	            test => inst_test );


end inst;

-- pragma translate_off
configuration DW_tap_inst_cfg_inst of DW_tap_inst is
  for inst
  end for; -- inst
end DW_tap_inst_cfg_inst;
-- pragma translate_on
