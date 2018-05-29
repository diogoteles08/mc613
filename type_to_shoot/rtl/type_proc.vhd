library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

entity type_proc is
  port (
    CLOCK_50 : in std_logic;
    PS2_DATA : inout STD_LOGIC;
    PS2_CLK : inout STD_LOGIC;
		VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS            : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
    VGA_CLK                   : out std_logic
  );
end type_proc;

architecture rtl of type_proc is

	component word_bank
		port (
			kill_word 		: in std_logic;
			word_to_kill	: in integer;
			new_word			: in word;
			words					: out word_table;
			num_words			: out integer
		);
	end component;

	component vga_ball
		port (
			CLOCK_50                  : in  std_logic;
			KEY                       : in  std_logic;
			NEW_WORD									: in word;
			LOCKED_WORD								: in word;
			LETTER_HIT								: in std_logic;
			WORD_DESTROYED						: in std_logic;
			VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
			VGA_HS, VGA_VS            : out std_logic;
			VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
			VGA_CLK                   : out std_logic;
			GAME_OVER									: out std_logic
		);
	end component;

	component keyboard_processor
		port (
			ps2_data	: inout std_logic;
			ps2_clk		:	inout	std_logic;
			clock 		: in std_logic;
			key_on		: out std_logic;
			asc_code	: out integer
		);
	end component;

	type statename is (
		LOCKED,
		FREE
	);

	signal locked_word_id: integer;
	signal locked_word: word;
	signal word_processed: word;
	signal new_word: word;

	signal active_words: word_table;
	signal num_active_words: integer;

	signal letter_hit: std_logic;
	signal kill_word: std_logic;

	signal key_on: std_logic;
	signal char_pressed: integer;

	signal stage: integer;
	signal game_over: std_logic;

begin
	bank: word_bank
		port map (
			kill_word 		=> kill_word,
			word_to_kill 	=> locked_word_id,
			new_word			=> new_word,
			words 				=> active_words,
			num_words 		=> num_active_words
		);

	keyboard: keyboard_processor
		port map (
			ps2_data 	=> PS2_DATA,
			ps2_clk 	=> PS2_CLk,
			clock			=> CLOCK_50,
			key_on		=> key_on,
			asc_code	=> char_pressed
		);

	screen_processor: vga_ball
		port map (
			CLOCK_50				=> CLOCK_50,
			KEY							=> '1',
			NEW_WORD				=> new_word,
			LOCKED_WORD 		=> locked_word,
			LETTER_HIT  		=> letter_hit,
			WORD_DESTROYED	=> kill_word,
			VGA_R						=> VGA_R,
			VGA_G						=> VGA_G,
			VGA_B						=> VGA_B,
			VGA_HS					=> VGA_HS,
			VGA_VS					=> VGA_VS,
			VGA_BLANK_N			=> VGA_BLANK_N,
			VGA_SYNC_N			=> VGA_SYNC_N,
			VGA_CLK					=> VGA_CLK,
			GAME_OVER				=> game_over
		);

end rtl;