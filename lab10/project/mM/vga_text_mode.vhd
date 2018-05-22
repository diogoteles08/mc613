library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library mM;
use mM.mM_pack.all;

entity vga_text_mode is
	generic (
		init_file1 : string := "";
		init_file2 : string := ""
	);	
	port(
		clk : in std_logic;
		reset : in std_logic;
		write: in std_logic_vector(1 downto 0);
		showmem : in std_logic;
		wa : in std_logic_vector(11 downto 0);
		wd : in std_logic_vector(7 downto 0);
		HS : out std_logic;
		VS : out std_logic;
		blank : out std_logic;
		column : out std_logic_vector(6 downto 0);
		row : out std_logic_vector(5 downto 0);
		pixel : out std_logic
	);
end vga_text_mode;

architecture a_vga_text_mode of vga_text_mode is
	-- references
	signal ra : std_logic_vector(11 downto 0);
	signal rd, rd0, rd1 : std_logic_vector(7 downto 0);
	signal rom_adr : std_logic_vector(10 downto 0);
	signal data : std_logic_vector(7 downto 0);
	signal memwrite : std_logic_vector(1 downto 0);
	
	-- auxiliaries
	signal pixel_x, pixel_y : std_logic_vector(9 downto 0);
	signal x_relative : integer range 0 to 7;
	signal y_relative : std_logic_vector(7 downto 0);
		
	-- delaying signals
	signal d1_x, d2_x, d1_y, d2_y : std_logic_vector(9 downto 0);
	signal tmp_HS, tmp_VS, tmp_blank, tmp_readnwrite : std_logic_vector(2 downto 0);
begin
	
	-- wiring
	VGA_SYNC: vga_timing
		port map(clk, reset, tmp_HS(0), tmp_VS(0), pixel_x, pixel_y, blank => tmp_blank(0)); 
			
	VGA_MEMORY1: ram
		generic map(12, 8, init_file1)
		port map(clk, write(0), ra, wa, wd, rd0);
		
	VGA_MEMORY2: ram
		generic map(12, 8, init_file2)
		port map(clk, write(1), ra, wa, wd, rd1);
	
	FONT_MEMORY: rom
		generic map(11, 8, "font.mif")
		port map(clk, rom_adr, data);
	
	-- choosing screen
	rd <= rd0 when showmem = '0' else rd1;
	
	-- delaying signals
	CLK1_X: flopar generic map(10) port map(clk, reset, pixel_x, d1_x);
	CLK2_X: flopar generic map(10) port map(clk, reset, d1_x, d2_x);
	CLK1_Y: flopar generic map(10) port map(clk, reset, pixel_y, d1_y);
	CLK2_Y: flopar generic map(10) port map(clk, reset, d1_y, d2_y);
	CLK1_BLANK: flopar generic map(1) port map(clk, reset, tmp_blank(0 downto 0), tmp_blank(1 downto 1));
	CLK2_BLANK: flopar generic map(1) port map(clk, reset, tmp_blank(1 downto 1), tmp_blank(2 downto 2));
	CLK1_HS: flopar generic map(1) port map(clk, reset, tmp_HS(0 downto 0), tmp_HS(1 downto 1));
	CLK2_HS: flopar generic map(1) port map(clk, reset, tmp_HS(1 downto 1), tmp_HS(2 downto 2));
	CLK1_VS: flopar generic map(1) port map(clk, reset, tmp_VS(0 downto 0), tmp_VS(1 downto 1));
	CLK2_VS: flopar generic map(1) port map(clk, reset, tmp_VS(1 downto 1), tmp_VS(2 downto 2));
	
	-- define character's pixel
	ra <= (pixel_y(8 downto 4) & "0000000") + pixel_x(9 downto 3);
	y_relative <= "0000" & d1_y(3 downto 0); 
	rom_adr <= (rd(6 downto 0) & "0000") + y_relative;	
	x_relative <= to_integer(unsigned(d2_x(2 downto 0)));
	
	-- drive outputs
	pixel <= data(7 - x_relative);
	blank <= tmp_blank(2);
	HS <= tmp_HS(2);
	VS <= tmp_VS(2);
	column <= d2_x(9 downto 3);
	row <= d2_y(9 downto 4);
	
end a_vga_text_mode;