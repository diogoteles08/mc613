library ieee;
use ieee.std_logic_1164.all;

entity zbuffer is 
	generic (N : INTEGER := 32);
	port (
		enable: in std_logic;
		Xin: in std_logic_vector(N-1 downto 0);
		Xout: out std_logic_vector(N-1 downto 0)
	);
end zbuffer;

architecture implement of zbuffer is 
begin
	Xout <= Xin when enable = '1' else (others => 'Z');
end implement;

