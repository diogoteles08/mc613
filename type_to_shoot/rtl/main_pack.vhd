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
	constant asc_A		: std_logic_vector(7 downto 0) := x"41";
	constant asc_B		: std_logic_vector(7 downto 0) := x"42";
	constant asc_C		: std_logic_vector(7 downto 0) := x"43";
	constant asc_D		: std_logic_vector(7 downto 0) := x"44";
	constant asc_E		: std_logic_vector(7 downto 0) := x"45";
	constant asc_F		: std_logic_vector(7 downto 0) := x"46";
	constant asc_G		: std_logic_vector(7 downto 0) := x"47";
	constant asc_H		: std_logic_vector(7 downto 0) := x"48";
	constant asc_I		: std_logic_vector(7 downto 0) := x"49";
	constant asc_J		: std_logic_vector(7 downto 0) := x"4A";
	constant asc_K		: std_logic_vector(7 downto 0) := x"4B";
	constant asc_L		: std_logic_vector(7 downto 0) := x"4C";
	constant asc_M		: std_logic_vector(7 downto 0) := x"4D";
	constant asc_N		: std_logic_vector(7 downto 0) := x"4E";
	constant asc_O		: std_logic_vector(7 downto 0) := x"4F";
	constant asc_P		: std_logic_vector(7 downto 0) := x"50";
	constant asc_Q		: std_logic_vector(7 downto 0) := x"51";
	constant asc_R		: std_logic_vector(7 downto 0) := x"52";
	constant asc_S		: std_logic_vector(7 downto 0) := x"53";
	constant asc_T		: std_logic_vector(7 downto 0) := x"54";
	constant asc_U		: std_logic_vector(7 downto 0) := x"55";
	constant asc_V		: std_logic_vector(7 downto 0) := x"56";
	constant asc_W		: std_logic_vector(7 downto 0) := x"57";
	constant asc_X		: std_logic_vector(7 downto 0) := x"58";
	constant asc_Y		: std_logic_vector(7 downto 0) := x"59";
	constant asc_Z		: std_logic_vector(7 downto 0) := x"5A";
	constant asc_enter	: std_logic_vector(7 downto 0) := x"0A";
	constant asc_space	: std_logic_vector(7 downto 0) := x"20";
	constant asc_escape	: std_logic_vector(7 downto 0) := x"1B";
	
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
