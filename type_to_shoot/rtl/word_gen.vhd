library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;
use work.word_base.all;

entity word_gen is	
	port (
		get_word		: in std_logic;
		new_word		: out word;
		new_word_size	: out integer
	);
end word_gen;

architecture rtl of word_gen is
	signal index: integer := 0;
begin
	process(get_word)		
	begin
		if get_word'EVENT and get_word = '1' then		
			if index = num_words-1 then
				index <= 0;
			else
				index <= index + 1;
			end if;
		end if;
		
		new_word <= str_to_std(word_base(index));
		new_word_size <= 4;
	end process;		
end rtl;
