library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;
use work.word_base.all;

entity word_gen is	
	port (
		reset				: in std_logic;
		get_word		: in std_logic;
		new_word		: out word;
		new_word_size	: out integer
	);
end word_gen;

architecture rtl of word_gen is
	signal index: integer := 0;
	signal word_len: integer := min_word_length;
begin
	process(get_word, reset)
	begin
		if reset = '0' then
			index <= 0;
			word_len <= min_word_length;

		elsif get_word'EVENT and get_word = '1' then
			if word_len /= max_word_length then
				word_len <= word_len + 1;
			else
				word_len <= min_word_length;
				if index /= words_by_num_letter-1 then
					index <= index + 1;					
				else					
					index <= 0;
				end if;
			end if;
		end if;
	end process;

	new_word <= str_to_std(word_base(index));
	new_word_size <= 4;

end rtl;
