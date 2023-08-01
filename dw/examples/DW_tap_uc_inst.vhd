library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_tap_uc_inst is
      generic (
	    inst_width : INTEGER := 8;
	    inst_id : INTEGER := 0;
	    inst_idcode_opcode : INTEGER := 1;
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
	    inst_device_id_sel : in std_logic;
	    inst_user_code_sel : in std_logic;
	    inst_user_code_val : in std_logic_vector(31 downto 0);
	    inst_ver : in std_logic_vector(3 downto 0);
	    inst_ver_sel : in std_logic;
	    inst_part_num : in std_logic_vector(15 downto 0);
	    inst_part_num_sel : in std_logic;
	    inst_mnfr_id : in std_logic_vector(10 downto 0);
	    inst_mnfr_id_sel : in std_logic;
	    clock_dr_inst : out std_logic;
	    shift_dr_inst : out std_logic;
	    update_dr_inst : out std_logic;
	    tdo_inst : out std_logic;
	    tdo_en_inst : out std_logic;
	    tap_state_inst : out std_logic_vector(15 downto 0);
	    instructions_inst : out std_logic_vector(inst_width-1 downto 0);
	    sync_capture_en_inst : out std_logic;
	    sync_update_dr_inst : out std_logic;
	    inst_test : in std_logic
	    );
    end DW_tap_uc_inst;


architecture inst of DW_tap_uc_inst is

begin

    -- Instance of DW_tap_uc
    U1 : DW_tap_uc
      generic map ( width => inst_width, 
                    id => inst_id, 
                    idcode_opcode => inst_idcode_opcode, 
                    version => inst_version, 
                    part => inst_part, 
                    man_num => inst_man_num, 
                    sync_mode => inst_sync_mode,
                    tst_mode => inst_tst_mode )
      port map ( tck => inst_tck, 
                 trst_n => inst_trst_n, 
                 tms => inst_tms, 
                 tdi => inst_tdi, 
                 so => inst_so, 
                 bypass_sel => inst_bypass_sel, 
                 sentinel_val => inst_sentinel_val, 
                 device_id_sel => inst_device_id_sel, 
                 user_code_sel => inst_user_code_sel, 
                 user_code_val => inst_user_code_val, 
                 ver => inst_ver, 
                 ver_sel => inst_ver_sel, 
                 part_num => inst_part_num, 
                 part_num_sel => inst_part_num_sel, 
                 mnfr_id => inst_mnfr_id, 
                 mnfr_id_sel => inst_mnfr_id_sel, 
                 clock_dr => clock_dr_inst, 
                 shift_dr => shift_dr_inst, 
                 update_dr => update_dr_inst, 
                 tdo => tdo_inst, 
                 tdo_en => tdo_en_inst, 
                 tap_state => tap_state_inst, 
                 instructions => instructions_inst, 
                 sync_capture_en => sync_capture_en_inst, 
                 sync_update_dr => sync_update_dr_inst, 
                 test => inst_test );


end inst;
