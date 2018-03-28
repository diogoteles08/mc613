library ieee;
use ieee.std_logic_1164.all;

entity xbar_v1 is
  port(x1, x2, s: in std_logic;
       y1, y2: out std_logic);
end xbar_v1;

architecture rtl of xbar_v1 is
begin
  -- with, select e when
	WITH s SELECT
		y1 <= x1 when '0',
				x2 when '1' ;
	WITH s SELECT
		y2 <= x2 when '0',
				x1 when '1' ;
	
end rtl;

