library ieee;
use ieee.std_logic_1164.all;

package main_pack is
	constant max_words: integer := 4; -- Defines the max number of words simultaneously on screen
	constant max_word_length: integer := 10; -- Defines the max length of any word on the game

	--subtype word is std_logic_vector(79 downto 0);
	type word is array (0 to 9) of integer;
	type array5 is array (0 to 4) of integer;
	type word_table is array (max_words-1 downto 0) of word;
end main_pack;