library ieee;
use ieee.std_logic_1164.all;

entity dec2_to_4 is
  port(en, w1, w0: in std_logic;
       y3, y2, y1, y0: out std_logic);
end dec2_to_4;

architecture rtl of dec2_to_4 is
	signal w: std_logic_vector(1 downto 0);
	signal y: std_logic_vector(3 downto 0);
begin
	w <= w1 & w0;
	
	y <= 	"0000" when en = '0' else
			"0001" when w = "00" else
			"0010" when w = "01" else
			"0100" when w = "10" else
			"1000" when w = "11";
			
	(y3, y2, y1, y0) <= y;
end rtl;

