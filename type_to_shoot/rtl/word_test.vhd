library ieee;
use ieee.std_logic_1164.all;

entity word_test is
	generic (		
		num_words: integer := 5
	);
  port (
    get_word : in std_logic;

		word: out string(1 to 2)
  );
end word_test;

architecture rtl of word_test is
begin	
	word <= "ab";
end rtl;