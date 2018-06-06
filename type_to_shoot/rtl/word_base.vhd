library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

package word_base is
	constant num_words: integer := 26;
	
	type word_arr is array(integer range 0 to num_words-1) of string(max_word_length downto 1);

	-- ONLY UPPER CASE
	constant word_base: word_arr := (
		"[[[[[[[[[A",
		"[[[[[[[[[B",
		"[[[[[[[[[C",
		"[[[[[[[[[D",
		"[[[[[[[[[E",
		"[[[[[[[[[F",
		"[[[[[[[[[G",
		"[[[[[[[[[H",
		"[[[[[[[[[I",
		"[[[[[[[[[J",
		"[[[[[[[[[K",
		"[[[[[[[[[L",
		"[[[[[[[[[M",
		"[[[[[[[[[N",
		"[[[[[[[[[O",
		"[[[[[[[[[P",
		"[[[[[[[[[Q",
		"[[[[[[[[[R",
		"[[[[[[[[[S",
		"[[[[[[[[[T",
		"[[[[[[[[[U",
		"[[[[[[[[[V",
		"[[[[[[[[[W",
		"[[[[[[[[[X",
		"[[[[[[[[[Y",
		"[[[[[[[[[Z"				
	);
end word_base;
