library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity h_function is
  port (
  nfsr_in :  in std_logic_vector (1 downto 0);
  lfsr_in :   in std_logic_vector (6 downto 0);	
  h_out     :  out std_logic
  );
end entity;

architecture arch of h_function is
signal x : std_logic_vector (8 downto 0);

begin

x(0) <= nfsr_in (1);
x(1) <= lfsr_in (6);
x(2) <= lfsr_in (5);
x(3) <= lfsr_in(4);
x(4) <= nfsr_in (0);
x(5) <= lfsr_in (3);
x(6) <= lfsr_in (2);
x(7) <= lfsr_in (1);
x(8) <=lfsr_in (0); 
h_out <= (x(0) and x(1)) xor (x(2) and x(3)) xor (x(4) and x(5)) xor (x(6) and x(7)) xor (x(0) and x(4) and x(8));
end architecture;
