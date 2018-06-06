library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package main_pack is
	constant max_words: integer := 5; -- Defines the max number of words simultaneously on screen
	constant max_word_length: integer := 10; -- Defines the max length of any word on the game	
		
	subtype char is std_logic_vector(7 downto 0);
	subtype word is std_logic_vector(max_word_length*8 - 1 downto 0);	
	type word_table is array (max_words-1 downto 0) of word;
	
	-- Number representing the space or no character
	constant no_char: std_logic_vector := "01011011"; -- 91
	constant no_word: std_logic_vector := no_char&no_char&no_char&no_char&no_char&no_char&no_char&no_char&no_char&no_char;
	constant no_table: word_table := (no_word, no_word, no_word, no_word, no_word);
	
	type array5 is array (0 to max_words-1) of integer;	
	
	-- asc values on std_vector
	constant letter_a: char := x"41"; -- A
	constant letter_b: char := x"42"; -- B
	constant letter_c: char := x"43"; -- C
	constant letter_d: char := x"44"; -- D
	constant letter_e: char := x"45"; -- E
	constant letter_f: char := x"46"; -- F
	constant letter_g: char := x"47"; -- G
	constant letter_h: char := x"48"; -- H
	constant letter_i: char := x"49"; -- I
	constant letter_j: char := x"4A"; -- J
	constant letter_k: char := x"4B"; -- K
	constant letter_l: char := x"4C"; -- L
	constant letter_m: char := x"4D"; -- M
	constant letter_n: char := x"4E"; -- N
	constant letter_o: char := x"4F"; -- O
	constant letter_p: char := x"50"; -- P
	constant letter_q: char := x"51"; -- Q
	constant letter_r: char := x"52"; -- R
	constant letter_s: char := x"53"; -- S
	constant letter_t: char := x"54"; -- T
	constant letter_u: char := x"55"; -- U
	constant letter_v: char := x"56"; -- V
	constant letter_w: char := x"57"; -- W
	constant letter_x: char := x"58"; -- X
	constant letter_y: char := x"59"; -- Y
	constant letter_z: char := x"5A"; -- Z
	
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
