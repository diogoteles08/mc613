library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package main_pack is
	constant max_words: integer := 4; -- Defines the max number of words simultaneously on screen
	constant max_word_length: integer := 5; -- Defines the max length of any word on the game
	
	-- Number representing the space or no character
	constant no_char: std_logic_vector := "01011011"; -- 91
	constant no_word: std_logic_vector := no_char&no_char&no_char&no_char&no_char&no_char&no_char&no_char;
	subtype word is std_logic_vector(max_word_length*8 - 1 downto 0);	
	type array5 is array (0 to 4) of integer;
	type word_table is array (max_words-1 downto 0) of word;
	
	-- Conversion functions
	function str_to_std(s: string) return std_logic_vector;
end main_pack;

package body main_pack is
	function str_to_std(s: string) return std_logic_vector is 
        constant ss: string(1 to s'length) := s; 
        variable answer: std_logic_vector(1 to 8 * s'length); 
        variable p: integer; 
        variable c: integer; 
    begin 
        for i in ss'range loop
            p := 8 * i;
            c := character'pos(ss(i));
            answer(p - 7 to p) := std_logic_vector(to_unsigned(c,8)); 
        end loop; 
        return answer; 
    end function; 
end main_pack;