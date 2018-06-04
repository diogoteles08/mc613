library ieee;
use ieee.std_logic_1164.all;

package main_pack is
	constant max_words: integer := 20; -- Defines the max number of words simultaneously on screen
	constant max_word_length: integer := 10; -- Defines the max length of any word on the game

	type array5 is array (0 to 4) of integer;
	type word is array (0 to max_word_length-1) of integer;
	type word_table is array (max_words-1 downto 0) of word;
end main_pack;