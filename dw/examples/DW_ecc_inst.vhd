library ieee, DWARE;
use ieee.std_logic_1164.all;
use DWARE.DW_foundation_comp.all;

entity DW_ecc_inst is
  generic (wdth: integer := 64;
           cbts: integer := 8 );
  port (allow_correct_n   : in  std_logic;
        wr_data_sys       : in  std_logic_vector(wdth-1 downto 0);
        rd_data_mem       : in  std_logic_vector(wdth-1 downto 0);
        rd_checkbits      : in  std_logic_vector(cbts-1 downto 0);
        rd_error          : out std_logic;
        real_bad_rd_error : out std_logic;
        wr_checkbits      : out std_logic_vector(cbts-1 downto 0);
        rd_data_sys       : out std_logic_vector(wdth-1 downto 0);
        error_syndrome    : out std_logic_vector(cbts-1 downto 0) );
end DW_ecc_inst;

architecture inst of DW_ecc_inst is
  signal logic_0, logic_1 : std_logic;
  signal bus_of_0s : std_logic_vector(cbts-1 downto 0);
begin

  -- instance of dw_ecc for memory reads, uses rd_data_mem
  -- and rd_checkbits to derive corrected data on rd_data_sys,
  -- error flags on rd_error & real_bad_rd_error, and error
  -- syndrome value on error_syndrome

  U1 : dw_ecc
    generic map (wdth, cbts, 1 )
    port map (logic_0,            -- gen tied low for read
              allow_correct_n,    -- correct_n from system
              rd_data_mem,        -- datain from memory
              rd_checkbits,       -- chkin also from memory
              rd_error,           -- error flag to system
              real_bad_rd_error,  -- error flag for multi errors
              rd_data_sys,        -- read data (corrected if allowed)
              error_syndrome );   -- error syndrome for logging

  logic_0 <= '0';

  -- instance of dw_ecc for memory writes, uses wr_data_sys to
  -- generate wr_checkbits; output ports err_detect, err_multpl, and
  -- dataout are not connected

  U2 : dw_ecc
    generic map ( width => wdth, chkbits => cbts, synd_sel => 0 )
    port map (gen => logic_1,             -- gen tied high for write
              correct_n => logic_1,       -- correct_n not needed (tied high)
              datain => wr_data_sys,      -- datain from system
              chkin => bus_of_0s,         -- chkin not needed (tied low)
              chkout => wr_checkbits );   -- chkout written to memory
  logic_1 <= '1';
  bus_of_0s <= (others => '0');
end inst;

