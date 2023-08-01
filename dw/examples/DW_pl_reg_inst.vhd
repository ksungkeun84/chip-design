library IEEE,DWARE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use DWARE.DWpackages.all;
use DWARE.DW_Foundation_comp.all;

entity DW_pl_reg_inst is
    generic (
	 inst_width : NATURAL := 8;
	 inst_in_reg : INTEGER := 0;	-- ignored in this design (pipe at output)
	 inst_stages : NATURAL := 4;
	 inst_out_reg : INTEGER := 0;
	 inst_rst_mode : INTEGER := 0
	 );
    port (
	 inst_clk : in std_logic;
	 inst_rst_n : in std_logic;
	 inst_enable : in std_logic_vector(inst_stages+inst_out_reg-2 downto 0);
	 inst_data_in : in std_logic_vector(inst_width-1 downto 0);
	 data_out_inst : out std_logic_vector(inst_width-1 downto 0)
	 );
    end DW_pl_reg_inst;

architecture inst of DW_pl_reg_inst is

  signal left_side, right_side : UNSIGNED((inst_width/2)-1 downto 0);
  signal product : std_logic_vector(inst_width-1 downto 0);

begin

  -- split input port, inst_data_in into two equal size multiplier operands
  --
  left_side  <= UNSIGNED(inst_data_in(inst_width-1 downto inst_width/2));
  right_side <= UNSIGNED(inst_data_in((inst_width/2)-1 downto 0));

  -- perform unsigned multiplication
  --
  product <= std_logic_vector(left_side * right_side);

    -- Then, pipeline the module using an instance of DW_pl_reg
    --
    U1 : DW_pl_reg
	generic map ( width => inst_width,
		      in_reg => 0,
		      stages => inst_stages,
		      out_reg => inst_out_reg,
		      rst_mode => inst_rst_mode )
	port map ( clk => inst_clk,
		   rst_n => inst_rst_n,
		   enable => inst_enable,
		   data_in => product,
		   data_out => data_out_inst );


end inst;
