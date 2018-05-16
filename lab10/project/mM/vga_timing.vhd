library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mM;
use mM.mM_pack.all;

entity vga_timing is
	port(
		clk : in std_logic;
		reset : in std_logic;
		HS : out std_logic;
		VS : out std_logic;
		pixel_x : out std_logic_vector(9 downto 0);
		pixel_y : out std_logic_vector(9 downto 0);
		last_column : out std_logic;
		last_row : out std_logic;
		blank : out std_logic
		);
end vga_timing;

architecture behavior of vga_timing is
	signal column : integer range 0 to 799;
	signal row : integer range 0 to 520;	
	signal new_row: std_logic;
	signal tmp_last_column, tmp_last_row, tmp_blank : std_logic_vector(1 downto 0);
	
begin
	
	-----------------------------
	----- Horizontal sync  ------
	-----------------------------
	process(reset, clk)
	begin
		if reset = '1' then
			column <= 0;
		elsif clk'event and clk = '1' then
			column <= column + 1;
			if column = 799 then
				column <= 0;
			end if;
		end if;
	end process;
	
	process(reset, clk)
	begin
		if reset = '1' then
			HS <= '1';
		elsif clk'event and clk = '1' then
			HS <= '1';
			if column > 654 and column < 751 then
				HS <= '0';
			end if;
		end if;
	end process;
	
	-----------------------------
	-----  Vertical sync   ------
	-----------------------------
	new_row <= '1' when column = 799 else '0';
	process(reset, clk)
	begin
		if reset = '1' then
			row <= 0;
		elsif clk'event and clk = '1' then
			if new_row = '1' then
				row <= row + 1;
				if row = 520 then
					row <= 0;
				end if;
			end if;
		end if;
	end process;
	
	process(reset, clk)
	begin
		if reset = '1' then
			VS <= '1';
		elsif clk'event and clk = '1' then
			VS <= '1';
			if  (row = 489 and new_row = '1') or 
				(row = 490) or 
				(row = 491 and new_row = '0') then
				VS <= '0';
			end if;
		end if;
	end process;
	
	-----------------------------
	-----     Outputs      ------
	-----------------------------
	tmp_last_column(1) <= '1' when column = 639 else '0';
	tmp_last_row(1) <= '1' when row = 479 else '0';
	tmp_blank(1) <= '1' when (column > 639 or row > 479) else '0';
	CLK1_X: flopar generic map(10) port map(clk, reset, std_logic_vector(to_unsigned(column, 10)), pixel_x);
	CLK1_Y: flopar generic map(10) port map(clk, reset, std_logic_vector(to_unsigned(row, 10)), pixel_y);
	CLK1_LCOL: flopar generic map(1) port map(clk, reset, tmp_last_column(1 downto 1), tmp_last_column(0 downto 0));
	CLK1_LROW: flopar generic map(1) port map(clk, reset, tmp_last_row(1 downto 1), tmp_last_row(0 downto 0));
	CLK1_BLANK: flopar generic map(1) port map(clk, reset, tmp_blank(1 downto 1), tmp_blank(0 downto 0));
	blank <= tmp_blank(0);
	last_column <= tmp_last_column(0);
	last_row <= tmp_last_row(0);

end behavior;