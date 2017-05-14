library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_textio.all;
  use std.textio.all;
  use work.fsr_taps_type.all;

entity grain128a_tb is
end entity;

architecture arch of grain128a_tb is
  component grain128a_top
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    new_key    : in  std_logic;
    key        : in  std_logic_vector (127 downto 0);
    IV         : in  std_logic_vector (95 downto 0);
    stream     : out std_logic_vector (GRAIN_STEP-1 downto 0);
    lfsr_state : out std_logic_vector (127 downto 0);
    nfsr_state : out std_logic_vector (127 downto 0)
  );
  end component grain128a_top;


constant clk_period : time := 10 ns;

--DUT signals
signal clk     : std_logic;
signal rst     : std_logic;
signal new_key : std_logic;
signal key     : std_logic_vector (127 downto 0);
signal IV      : std_logic_vector (95 downto 0);
signal stream  : std_logic_vector (GRAIN_STEP-1 downto 0);
signal save_stream  : std_logic_vector (319 downto 0);
signal lfsr_state : std_logic_vector (127 downto 0);
signal nfsr_state : std_logic_vector (127 downto 0);

signal lfsr_out : std_logic_vector (127 downto 0);
signal nfsr_out : std_logic_vector (127 downto 0);
signal lfsr_error      : std_logic;
signal nfsr_error      : std_logic;
signal keystream_OK	: std_logic;

shared variable i :  integer range 0 to 1024;
signal i_sig    :   integer range 0 to 1024;
signal row_counter : integer:=0;
shared variable row         : line;
shared variable row_data    : std_logic_vector(127 downto 0);

signal loop_end		: std_logic;


--file input_data : text open read_mode is "/h/d7/w/ja8602ga-s/Crypto/grain_state.txt";


begin
clock_gen : process
begin
  clk <= '1';
  wait for clk_period/2;
  clk <= '0';
  wait for clk_period/2;
end process;

stim_process : process
begin
  rst <= '1';
  new_key <= '1';
  wait for 1.5*clk_period;
  rst <= '0';
  new_key <= '1';
  key <= (others => '0');
  IV <= (others => '0');
  --IV (95 downto 4) <= (others => '0');
  --IV (3 downto 0) <= "0001";
  wait for clk_period;
  new_key <= '0';
  wait for clk_period;
  while loop_end = '0' loop
  wait for clk_period;
  end loop;
  new_key <= '1';
  key <= (others => '0');
  IV <= (others => '0');
  wait for 1.5*clk_period;
  new_key <= '0';
  wait;
end process;

save_stream_proc : process

begin
  i:=0;
  i_sig <= i;
  save_stream <= (others => '0');
  loop_end <= '0';
while rst = '1' loop
end loop;
wait for 4*clk_period;
while (i<(256/GRAIN_STEP)-1) loop
  loop_end <= '0';
  i := i+1;
  i_sig <= i;
  wait for clk_period;
end loop;
i := 0;
--if IV(0) = '1' then
  --wait for 66*clk_period;     -- Key-stream with auth
--else
  wait for clk_period;        -- Pre-output
--end if;
while (i<=(320/GRAIN_STEP)-1) loop
  save_stream <= save_stream ((319-GRAIN_STEP) downto 0) & stream;
  i := i+1;
  i_sig <= i;
  --if IV(0) = '1' then
    --wait for 2*clk_period;    -- Keystream
  --else
    wait for clk_period;        -- Pre-output
  --end if;
end loop;

loop_end <= '1';
wait for clk_period;
while new_key = '1' loop
 i:= 0;
 i_sig <= i;
 wait for clk_period;
end loop;
wait for clk_period;

--LOOP 2

while (i<255) loop
  loop_end <= '0';
  i := i+1;
  i_sig <= i;
  wait for clk_period;
end loop;
i:=0;
save_stream <= (others => '0');
--if IV(0) = '1' then
  --wait for 66*clk_period;     -- Key-stream with auth
--else
  wait for clk_period;        -- Pre-output
--end if;
while (i<=320) loop
  save_stream <= save_stream ((319-GRAIN_STEP) downto 0) & stream;
  i := i+1;
  i_sig <= i;
  --if IV(0) = '1' then
    --wait for 2*clk_period;    -- Keystream
  --else
    wait for clk_period;        -- Pre-output
  --end if;
end loop;

wait;
end process;

--file_process: process
--begin
--    row_counter <= 0;
--    wait for 4*clk_period;
--    while not endfile(input_data) and row_counter < 256 loop
--        readline(input_data,row);
--        read (row,row_data);
--	lfsr_state <= row_data;
--        readline(input_data,row);
--        read (row,row_data);
--	nfsr_state <= row_data;
--	row_counter <= row_counter + 1;
--	wait for clk_period;
--    end loop;
--    wait;
--end process;

compare_process: process(lfsr_state,lfsr_out,nfsr_state,nfsr_out)
begin

    if lfsr_state = lfsr_out then
      lfsr_error <= '0';
    else
      lfsr_error <= '1';
    end if;

    if nfsr_state = nfsr_out then
      nfsr_error <= '0';
    else
      nfsr_error <= '1';
    end if;
end process;

uut : grain128a_top
port map (
  clk     => clk,
  rst     => rst,
  new_key => new_key,
  key     => key,
  IV      => IV,
  stream  => stream,
  lfsr_state => lfsr_out,
  nfsr_state => nfsr_out
);

end architecture;
