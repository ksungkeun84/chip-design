library IEEE,WORK,DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;

entity DW_ram_2r_2w_s_dff_inst is
      generic (
	    width : INTEGER := 8;
	    addr_width : INTEGER := 3;
	    rst_mode : INTEGER := 0
	    );
      port (
	    clk : in std_logic;
	    rst_n : in std_logic;
	    en_w1_n : in std_logic;
	    addr_w1 : in std_logic_vector(addr_width-1 downto 0);
	    data_w1 : in std_logic_vector(width-1 downto 0);
	    en_w2_n : in std_logic;
	    addr_w2 : in std_logic_vector(addr_width-1 downto 0);
	    data_w2 : in std_logic_vector(width-1 downto 0);
	    en_r1_n : in std_logic;
	    addr_r1 : in std_logic_vector(addr_width-1 downto 0);
	    data_r1 : out std_logic_vector(width-1 downto 0);
	    en_r2_n : in std_logic;
	    addr_r2 : in std_logic_vector(addr_width-1 downto 0);
	    data_r2 : out std_logic_vector(width-1 downto 0)
	    );
    end DW_ram_2r_2w_s_dff_inst;


architecture inst of DW_ram_2r_2w_s_dff_inst is

    component DW_ram_2r_2w_s_dff
      generic (
	    width : INTEGER := 8;
	    addr_width : INTEGER := 3;
	    rst_mode : INTEGER := 0
	    );
      port (
	    clk : in std_logic;
	    rst_n : in std_logic;

	    en_w1_n : in std_logic;
	    addr_w1 : in std_logic_vector(addr_width-1 downto 0);
	    data_w1 : in std_logic_vector(width-1 downto 0);

	    en_w2_n : in std_logic;
	    addr_w2 : in std_logic_vector(addr_width-1 downto 0);
	    data_w2 : in std_logic_vector(width-1 downto 0);

	    en_r1_n : in std_logic;
	    addr_r1 : in std_logic_vector(addr_width-1 downto 0);
	    data_r1 : out std_logic_vector(width-1 downto 0);

	    en_r2_n : in std_logic;
	    addr_r2 : in std_logic_vector(addr_width-1 downto 0);
	    data_r2 : out std_logic_vector(width-1 downto 0)
	    );
    end component;

begin

    -- Instance of DW_ram_2r_2w_s_dff
    U1 : DW_ram_2r_2w_s_dff
	generic map ( width => width,
		      addr_width => addr_width,
		      rst_mode => rst_mode )

	port map (  clk => clk, rst_n => rst_n,
		    en_w1_n => en_w1_n, addr_w1 => addr_w1, data_w1 => data_w1,
		    en_w2_n => en_w2_n, addr_w2 => addr_w2, data_w2 => data_w2,
		    en_r1_n => en_r1_n, addr_r1 => addr_r1, data_r1 => data_r1,
		    en_r2_n => en_r2_n, addr_r2 => addr_r2, data_r2 => data_r2 );


end inst;
