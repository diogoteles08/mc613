library ieee;
use ieee.std_logic_1164.all;

entity xbar_v3 is
  generic( n: INTEGER :=5);
  port(x1, x2, s: in std_logic;
       y1, y2: out std_logic);
end xbar_v3;

architecture rtl of xbar_v3 is
BEGIN
  -- using process
  process (s)
	begin
		if s = '0' then
			y1 <= x1;
		else
			y1 <= x2;
		end if;
		
		if s = '1' then
			y2 <= x1;
		else
			y2 <= x2;
		end if;
  end process ;
 
end rtl;

