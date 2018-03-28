library ieee;
use ieee.std_logic_1164.all;

entity xbar_stage_8 is
  port(SW  : in std_logic_vector (7 downto 0);
       LEDR: out std_logic_vector(0 downto 0));
end xbar_stage_8;

architecture rtl of xbar_stage_8 is
	component xbar_gen
		GENERIC ( n : INTEGER := 8);
		port(s: in std_logic_vector (N-1 downto 0);
			  y1, y2: out std_logic);
	end component;
BEGIN
	xbar_8: xbar_gen
	generic map (N => 8)
	-- duvidas em LEDR => y1, so pego um deles?? faz sentido ateh
	port map ( 
				s => SW,
			   y1 => LEDR(0) );
end rtl;

