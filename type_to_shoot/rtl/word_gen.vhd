library ieee;
use ieee.std_logic_1164.all;
use work.main_pack.all;

entity word_gen is
	generic (
		-- this generic should not be changed/defined on implementation, since
		-- we define the words directly on code
		num_words: integer := 5
	);
	port (
		get_word		: in std_logic;
		new_word		: out word;
		new_word_size	: out integer
	);
end word_gen;

architecture rtl of word_gen is
	type word_arr is array(integer range 0 to num_words-1) of word;
	signal word_base: word_arr;
begin	

	process(get_word)
		variable index: integer := 0;
	begin
		if get_word'EVENT and get_word = '1' then		
			if index = num_words-1 then
				index := 0;
			else
				index := index + 1;
			end if;
		end if;
		
		new_word <= word_base(index);
	end process;
		
		word_base <= (
			(others => 41),
			(others => 42),
			(others => 43),
			(others => 44),
			(others => 45)
		);
--	word_base <= (
--		x"41414141414141414141",
--		x"42424242424242424242",
--		x"43434343434343434343",
--		x"44444444444444444444",
--		x"45454545454545454545"
--	);
end rtl;
