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
		words: out word_table;
		num_words: out integer -- Number less than or equals to max_words
  );
end word_bank;

architecture rtl of word_bank is
	signal words_aux: word_table;
	signal num_words_aux: integer := 0;
begin
	process(kill_word, new_word)
	begin
		if new_word'EVENT then
			words_aux(num_words_aux) <= new_word;
			num_words_aux <= num_words_aux + 1;
		end if;
		
		if kill_word'EVENT and kill_word = '1' then
			-- Does the shift
			for i in word_to_kill to num_words_aux-2 loop
				words_aux(i) <= words_aux(i+1);
			end loop;
			
			num_words_aux <= num_words_aux - 1;
			words_aux(num_words_aux) <= (others => 0); -- Limpa o espaco no fim da lista
		end if;		
	end process;
	
	words <= words_aux;
	num_words <= num_words_aux;
end rtl;