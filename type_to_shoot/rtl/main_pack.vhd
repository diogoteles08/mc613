library ieee;
use ieee.std_logic_1164.all;

package main_pack is 
	subtype word is string(1 to 10);
	type char_arr is array(integer range 0 to 1) of character;

end main_pack;