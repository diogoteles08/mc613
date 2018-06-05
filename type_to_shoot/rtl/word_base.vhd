library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

package word_base is
	constant num_words: integer := 5;
	
	type word_arr is array(integer range 0 to num_words-1) of string(max_word_length downto 1);

	-- ONLY UPPER CASE
	constant word_base: word_arr := (
		"BOBOA",
		"BABAO",
		"PAPAI",
		"GUIDO",
		"PATA "
	);
end word_base;