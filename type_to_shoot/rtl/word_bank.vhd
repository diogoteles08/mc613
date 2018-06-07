library ieee;
use ieee.std_logic_1164.all;
use work.main_pack.all;

entity word_bank is	
  port (
		reset							: in std_logic;
		clock							: in std_logic;
		kill_word					: in std_logic;
		word_to_kill_index: in integer;
		insert_new_word		: in std_logic;
		new_word					: in word;
		words							: out word_table;
		num_words					: out integer -- Number less than or equals to max_words
  );
end word_bank;

architecture rtl of word_bank is
begin
	-- insercao e remocao podem ser feitos ao mesmo tempo, soh da erro quando
	-- o numero de palavras jah eh o maximo e se tenta excluir e inserir ao mesmo tempo
	process(clock)
		variable words_aux: word_table := no_table;
		variable num_words_aux: integer := 0;
	begin		
		if clock'event and clock = '1' then
			if reset = '0' then
				num_words_aux := 0;
				words_aux := no_table;
			elsif
				if insert_new_word = '1' then
					words_aux(num_words_aux) := new_word;
					num_words_aux := num_words_aux + 1;
				end if;
			
				if kill_word = '1' then
					-- Does the shift
					for i in 0 to max_words-2 loop
						if i >= word_to_kill_index and i <= num_words_aux-2 then
							words_aux(i) := words_aux(i+1);
						end if;
					end loop;

					num_words_aux := num_words_aux - 1;
					words_aux(num_words_aux) := no_word; -- Limpa o espaco no fim da lista
				end if;
			end if;
		end if;

		words <= words_aux;
		num_words <= num_words_aux;
	end process;
end rtl;