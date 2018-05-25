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
    get_word : in std_logic;
--		test: out std_logic

		char: out char_arr
--		new_word: out string(1 to 10)
  );
end word_gen;

architecture rtl of word_gen is
--	type word_arr is array(integer range 0 to num_words-1) of word;
--	signal word_base: word_arr;
begin	

--	process(get_word)
--		variable index: integer := 0;
--	begin
--		if index = num_words-1 then
--			index := 0;
--		else
--			index := index + 1;
--		end if;
--		
--		new_word <= word_base(index);
--	end process;
		
--	word_base <= (
--		"aaaaaaaaaa",
--		"bbbbbbbbbb",
--		"cccccccccc",
--		"dddddddddd",
--		"eeeeeeeeee"
--	);
	
--	new_word <= word_base(0);
--		new_word <= "aaaaaaaaaa";
--		test <= '1';
		char <= "ab";
end rtl;