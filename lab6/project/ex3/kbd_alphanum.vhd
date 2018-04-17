library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
	
	signal key : std_logic_vector(7 downto 0); -- Because we are looking only for the first 8bits of the key_code
	signal ascCode: std_logic_vector(7 downto 0);
	signal case_shifter: std_logic_vector(7 downto 0);
	signal h0: std_logic_vector(3 downto 0);
	signal h1: std_logic_vector(3 downto 0);
begin
  
  -- first we need to check shift and capslock
  -- secondly we need to convert key_code to ascii    
  
  process( clk )
  -- espaco para as variables
  variable shift: std_logic;
  variable caps: std_logic;  
  variable aux_0: std_logic_vector(7 downto 0) := "00000000";
  begin
		shift := '0';
			
		if key_code(7 downto 0) /= x"12" and key_code(7 downto 0) /= x"59" then
			key <= key_code(7 downto 0);
		else 
			shift := '1';			
			if key_code(23 downto 16) /= x"12" and key_code(23 downto 16) /= x"59" then
				key <= key_code(23 downto 16);
			else 
				key <= key_code(39 downto 32);
			end if;
		end if;
		
		if (shift xor caps) = '1' then
			case_shifter <= "11100000"; -- -32
		else 
			case_shifter <= "00000000";
		end if;
		
		case key is
			when x"58" => 
				caps := not caps;
			
			when x"1C" => 
				ascCode <= 97 + case_shifter;
			when x"32" => 
				ascCode <= 98 + case_shifter;
			when x"21" => 
				ascCode <= 99 + case_shifter;
			when x"23" => 
				ascCode <= 100 + case_shifter;
			when x"24" => 
				ascCode <= 101 + case_shifter;
			when x"2B" => 
				ascCode <= 102 + case_shifter;
			when x"34" => 
				ascCode <= 103 + case_shifter;
			when x"33" => 
				ascCode <= 104 + case_shifter;
			when x"43" => 
				ascCode <= 105 + case_shifter;
			when x"3B" => 
				ascCode <= 106 + case_shifter;
			when x"42" => 
				ascCode <= 107 + case_shifter;
			when x"4B" => 
				ascCode <= 108 + case_shifter;
			when x"3A" => 
				ascCode <= 109 + case_shifter;
			when x"31" => 
				ascCode <= 110 + case_shifter;
			when x"44" => 
				ascCode <= 111 + case_shifter;
			when x"4D" => 
				ascCode <= 112 + case_shifter;
			when x"15" => 
				ascCode <= 113 + case_shifter;
			when x"2D" => 
				ascCode <= 114 + case_shifter;
			when x"1B" => 
				ascCode <= 115 + case_shifter;
			when x"2C" => 
				ascCode <= 116 + case_shifter;
			when x"3C" => 
				ascCode <= 117 + case_shifter;
			when x"2A" => 
				ascCode <= 118 + case_shifter;
			when x"1D" => 
				ascCode <= 119 + case_shifter;
			when x"22" => 
				ascCode <= 120 + case_shifter;
			when x"35" => 
				ascCode <= 121 + case_shifter;
			when x"1A" => 
				ascCode <= 122 + case_shifter;

			when x"45" => 
				ascCode <= 48 + aux_0;
			when x"70" => 
				ascCode <= 48 + aux_0;
			when x"16" => 
				ascCode <= 49 + aux_0;
			when x"69" => 
				ascCode <= 49 + aux_0;
			when x"1E" => 
				ascCode <= 50 + aux_0;
			when x"72" => 
				ascCode <= 50 + aux_0;
			when x"26" => 
				ascCode <= 51 + aux_0;
			when x"7A" => 
				ascCode <= 51 + aux_0;
			when x"25" => 
				ascCode <= 52 + aux_0;
			when x"6B" => 
				ascCode <= 52 + aux_0;
			when x"2E" => 
				ascCode <= 53 + aux_0;
			when x"73" => 
				ascCode <= 53 + aux_0;
			when x"36" => 
				ascCode <= 54 + aux_0;
			when x"74" => 
				ascCode <= 54 + aux_0;
			when x"3D" => 
				ascCode <= 55 + aux_0;
			when x"6C" => 
				ascCode <= 55 + aux_0;
			when x"3E" => 
				ascCode <= 56 + aux_0;
			when x"75" => 
				ascCode <= 56 + aux_0;
			when x"46" => 
				ascCode <= 57 + aux_0;
			when x"7D" => 
				ascCode <= 57 + aux_0;
			when others =>
				ascCode <= aux_0;
		end case;
	
		h0 <= ascCode(3 downto 0);
		h1 <= ascCode(7 downto 4);
		
  end process;
  
	d0: bin2hex port map(
		SW => h0,
		HEX0 => HEX0
	);
	d1: bin2hex port map(
		SW => h1,
		HEX0 => HEX1
	);  
  
end rtl;
