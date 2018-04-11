library ieee;
use ieee.std_logic_1164.all;

entity dec3_to_8 is 	
	port (		
		en: in std_logic;
		Xin: in std_logic_vector(2 downto 0);
		Xout: out std_logic_vector(7 downto 0)
	);
end dec3_to_8;

architecture implement of dec3_to_8 is 
begin
	Xout <= "00000000" when en = '0' else
			"00000001" when Xin = "000" else
			"00000010" when Xin = "001" else
			"00000100" when Xin = "010" else
			"00001000" when Xin = "011" else
			"00010000" when Xin = "100" else
			"00100000" when Xin = "101" else
			"01000000" when Xin = "110" else
			"10000000" when Xin = "111";
end implement;