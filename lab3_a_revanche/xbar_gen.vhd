library ieee;
use ieee.std_logic_1164.all;

entity xbar_gen is
  GENERIC ( n : INTEGER := 5);
  port(s: in std_logic_vector (N-1 downto 0);
		 y1, y2: out std_logic);
end xbar_gen;

architecture rtl of xbar_gen is
	component xbar_v3
		generic( n: INTEGER :=5);
				port(x1, x2, s: in std_logic;
				y1, y2: out std_logic);
	end component;
	signal aux1: std_logic_vector (N downto 0);
	signal aux2: std_logic_vector (N downto 0);
begin
	
	aux1(0) <= '1';
	aux2(0) <= '0';
	
	Generate_label:
	for i in 0 to n-1 generate
		stage: xbar_v3 PORT MAP(aux1(i), aux2(i), s(i), aux1(i+1), aux2(i+1)) ;
	end generate;
	
	y1 <= aux1(n);
	y2 <= aux2(n);
	
end rtl;

