library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.fsr_taps_type.all;

entity stream_cipher_tb is
end entity;

architecture testbench of stream_cipher_tb is

component stream_cipher_top is
  port (
  clk           : in std_logic;
  rst           : in std_logic;
  start_attack  : in std_logic;
  new_key       : in std_logic;
  key_in   : in std_logic_vector (3 downto 0);
  mask_in  : in std_logic_vector (3 downto 0);
  WEB           : in std_logic;
  REN			: in std_logic;
  reg_full      : out std_logic;
  attack_finished : out std_logic;
  signature_out : out std_logic_vector (7 downto 0);
  grain128a_out : out std_logic_vector (GRAIN_STEP-1 downto 0);
  espresso_out  : out std_logic
   );
end component;


signal clk,rst,start_attack,new_key,WEB,REN,reg_full : std_logic;
signal key_in,mask_in	:	std_logic_vector(3 downto 0);
signal grain128a_out : std_logic_vector (GRAIN_STEP-1 downto 0);
signal espresso_out : std_logic;

signal key	:	std_logic_vector (127 downto 0) := (others => '0');
signal IV	:	std_logic_vector (95 downto 0) := (others => '0');
signal key_mask : std_logic_vector (127 downto 0);
signal IV_mask  : std_logic_vector (95 downto 0);
signal save_grain : std_logic_vector (319 downto 0);
shared variable i :  integer range 0 to 1024 := 0;
shared variable j :  integer range 0 to 1024 := 0;

constant clk_period : time := 5 ns;

begin

clkproc: process
begin
	clk <= '1';
	wait for clk_period/2;
	clk <= '0';
	wait for clk_period/2;
end process;

stimproc: process
begin
	rst <= '1';
	wait for clk_period;
	rst <= '0';
	wait;
end process;

datainproc: process
begin
	WEB <= '0';
	REN <= '0';
	new_key <= '0';
	key_in <= (others => '0');
  	mask_in <= (others => '0');
  	start_attack <= '0';
  	key_mask <= (others => '0');
  	IV_mask <= (64 => '1',58 => '1',61 => '1',44 => '1', others => '0');
	wait until rst = '0';

	for I in 0 to 23 loop
		WEB <= '1';
		for J in 0 to 3 loop
			key_in (J) <= IV (4*I+J);
			mask_in (J) <= IV_mask (4*I+J);
		end loop;	
		wait for clk_period;
	end loop;	

	for I in 0 to 31 loop
		WEB <= '1';
		for J in 0 to 3 loop
			key_in (J) <= key(4*I+J);
			mask_in (J) <= key_mask (4*I+J);
		end loop;	
		wait for clk_period;
	end loop;

	WEB <='0';
	start_attack <= '1';
	wait for clk_period;
	start_attack <= '0';
	wait;
end process;

savegrainproc: process
begin
	wait until new_key = '0';
	save_grain <= (others => '0');
	wait until new_key = '1';
	wait until new_key = '0';

	wait for 3*clk_period;
	while (i<(256/GRAIN_STEP)-1) loop	-- Wait initialisation rounds
	  i := i+1;
	  wait for clk_period;
	end loop;
	i:=0;
	wait for 66*clk_period;
	while (i<=(320/GRAIN_STEP)-1) loop
	  save_grain <= save_grain ((319-GRAIN_STEP) downto 0) & grain128a_out;
	  i := i+1;
	  wait for 2*clk_period;    -- Key-stream with auth
	end loop;
	wait;
end process;

uut : stream_cipher_top
port map (
  clk           => clk,
  rst           => rst,
  start_attack  => start_attack,
  new_key       => new_key,
  key_in        => key_in,
  mask_in       => mask_in,
  REN			=> REN,
  WEB           => WEB,
  reg_full      => reg_full,
  grain128a_out => grain128a_out,
  espresso_out  => espresso_out
);


end architecture;
