library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

package word_base is
	constant num_words: integer := 5;
	type word_arr is array(integer range 0 to num_words-1) of word;
	
	constant word_base: word_arr := (
		x"41414141414141414141",
		x"42424242424242424242",
		x"43434343434343434343",
		x"44444444444444444444",
		x"45454545454545454545"
	);
end word_base;