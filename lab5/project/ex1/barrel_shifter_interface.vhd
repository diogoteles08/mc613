-- brief : lab05 - question 1

library ieee;
use ieee.std_logic_1164.all;

entity barrel_shifter_interface is
  port(
    SW : in  std_logic_vector (5 downto 0);
    LEDR : out std_logic_vector (3 downto 0)
  );
end barrel_shifter_interface;

architecture rtl of barrel_shifter_interface is
	
	component barrel_shifter port(
		w : in  std_logic_vector (3 downto 0);
		s : in  std_logic_vector (1 downto 0);
		y : out std_logic_vector (3 downto 0)
		);
	end component;
			 
begin

	my_barrel: barrel_shifter port map (
		w => SW(3 downto 0),
		s => SW(5 downto 4),
		y => LEDR 
	);
end rtl;

