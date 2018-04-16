library ieee;
use ieee.std_logic_1164.all;

entity kbd_alphanum is
  port (
    clk : in std_logic;
    key_on : in std_logic_vector(2 downto 0);
    key_code : in std_logic_vector(47 downto 0);
    HEX1 : out std_logic_vector(6 downto 0); -- GFEDCBA
    HEX0 : out std_logic_vector(6 downto 0) -- GFEDCBA
  );
end kbd_alphanum;

architecture rtl of kbd_alphanum is
-- tudo que eh preciso fazer eh pegar o key_code e o key_on 
-- e transcrever as informacoes que podem estar nesses dois 
-- vetores em dois displays de 7 segmentos
	component bin2hex 
		port (
		SW: in std_logic_vector(3 downto 0);
		HEX0: out std_logic_vector(6 downto 0)
		);
	end component;
	
	signal t1 : std_logic_vector(3 downto 0);
	signal t2 : std_logic_vector(3 downto 0);
begin
  
  -- first we need to check shift and capslock
  -- secondly we need to convert key_code to ascii
  
  if 
  
  
  process( clk )
  -- espaco para as variables
  begin
		with key_on select
			-- no key is pressed
			if key_on = "000" then
					t1 <= "0000";
					t2 <= "0000";
			elsif key_on = "001" then
					if key_code = x"1C" then t1 <= 
					elsif key_code = x"32" then
					elsif key_code = x"21" then
					elsif key_code = x"23" then
					elsif key_code = x"24" then
					elsif key_code = x"2B" then
					elsif key_code = x"34" then
					elsif key_code = x"33" then
					elsif key_code = x"43" then
					elsif key_code = x"3B" then
					elsif key_code = x"42" then
					elsif key_code = x"4B" then
					elsif key_code = x"3A" then
					elsif key_code = x"31" then
					elsif key_code = x"44" then
					elsif key_code = x"4D" then
					elsif key_code = x"15" then
					elsif key_code = x"2D" then
					elsif key_code = x"1B" then
					elsif key_code = x"2C" then
					elsif key_code = x"3C" then
					elsif key_code = x"2A" then
					elsif key_code = x"1D" then
					elsif key_code = x"22" then
					elsif key_code = x"35" then
					elsif key_code = x"1A" then
					elsif key_code = x"45" then
					elsif key_code = x"16" then
					elsif key_code = x"1E" then
					elsif key_code = x"26" then
					elsif key_code = x"3D" then
					elsif key_code = x"3E" then
					elsif key_code = x"46" then
					elsif key_code = x"70" then
					elsif key_code = x"69" then
					elsif key_code = x"72" then
					elsif key_code = x"7A" then
					elsif key_code = x"73" then
					elsif key_code = x"74" then
					elsif key_code = x"6C" then
					elsif key_code = x"75" then
					elsif key_code = x"7D" then
					elsif key_code = x"12" then
					elsif key_code = x"59" then
					elsif key_code = x"58" then
					
			elsif key_on = "011" then
			
			elsif key_on = "111" then
			
			end if;
		
  end process;
  
  d1: bin2hex port map(
	SW => BLA,
	HEX0 => HEX1
  );
  d2: bin2hex port map(
	SW => BLA,
	HEX0 => HEX0
  );
  
end rtl;
