library ieee;
use ieee.std_logic_1164.all;
use work.main_pack.all;

entity word_bank is
	generic (		
		max_words: integer := 20
	);
  port (
    kill_word : in std_logic;
		word_to_kill: in integer;
		new_word: in word;
		words_out: out word_table;
		num_words_out: out integer -- Number less than or equals to max_words
  );
end word_bank;

architecture rtl of word_bank is
	signal words: word_table;
	signal num_words: integer := 0;
begin
	process(kill_word, new_word)
	begin
		if new_word'EVENT then
			words(num_words) <= new_word;
			num_words <= num_words + 1;
		end if;
		
		if kill_word'EVENT and kill_word = '1' then
			-- Does the shift
			for i in word_to_kill to num_words-2 loop
				words(i) <= words(i+1);
			end loop;
			
			num_words <= num_words - 1;
			words(num_words) <= (others => 0); -- Limpa o espaco no fim da lista
		end if;		
	end process;
	
	words_out <= words;
	num_words_out <= num_words;
end rtl;