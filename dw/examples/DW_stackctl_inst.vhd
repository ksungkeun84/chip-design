library IEEE,DWARE,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use DWARE.DW_foundation_comp.all;

entity DW_stackctl_inst is
  generic (inst_depth    : INTEGER := 8;
           inst_err_mode : INTEGER := 0;
           inst_rst_mode : INTEGER := 0  );
  port (inst_clk       : in std_logic;
        inst_rst_n     : in std_logic;
        inst_push_req_n: in std_logic;
        inst_pop_req_n : in std_logic;
        we_n_inst   : out std_logic;
        empty_inst  : out std_logic;
        full_inst   : out std_logic;
        error_inst  : out std_logic;
        wr_addr_inst: out std_logic_vector(bit_width(inst_depth)-1 downto 0);
        rd_addr_inst: out std_logic_vector(bit_width(inst_depth)-1 downto 0)
        );
end DW_stackctl_inst;

architecture inst of DW_stackctl_inst is
begin

  -- Instance of DW_stackctl
  U1 : DW_stackctl
    generic map (depth => inst_depth,   err_mode => inst_err_mode, 
                 rst_mode => inst_rst_mode )
    port map (clk => inst_clk,   rst_n => inst_rst_n, 
              push_req_n => inst_push_req_n,   pop_req_n => inst_pop_req_n,
              we_n => we_n_inst,   empty => empty_inst,   full => full_inst,
              error => error_inst,   wr_addr => wr_addr_inst, 
              rd_addr => rd_addr_inst );
end inst;

-- pragma translate_off
configuration DW_stackctl_inst_cfg_inst of DW_stackctl_inst is
  for inst
  end for; -- inst
end DW_stackctl_inst_cfg_inst;
-- pragma translate_on

