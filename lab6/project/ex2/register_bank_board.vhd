library ieee;
use ieee.std_logic_1164.all;

entity register_bank_board is
  port (
    KEY : in std_logic_vector(2 downto 0);
	 SW: in std_logic_vector(9 downto 0);
    HEX0 : out std_logic_vector(6 downto 0)
  );
end register_bank_board;

architecture structural of register_bank_board is	
	component register_bank
		port (
			clk : in std_logic;
			 data_in : in std_logic_vector(3 downto 0);
			 data_out : out std_logic_vector(3 downto 0);
			 reg_rd : in std_logic_vector(2 downto 0);
			 reg_wr : in std_logic_vector(2 downto 0);
			 we : in std_logic;
			 clear : in std_logic
		);
	end component;
	signal bin : std_logic_vector(3 downto 0);	
begin	
  bla: register_bank port map (
	clk => not (KEY(0)),
	data_in => SW(9 downto 6),
	data_out => bin,
	reg_rd => SW(5 downto 3),
	reg_wr => SW(2 downto 0),
	we => not (KEY(1)),
	clear => KEY(2)
  );
    
	WITH bin SELECT
		HEX0 <=  "1000000" WHEN "0000",
					"1111001" WHEN "0001", 
					"0100100" WHEN "0010",
					"0110000" WHEN "0011",
					"0011001" WHEN "0100",
					"0010010" WHEN "0101",
					"0000010" WHEN "0110",
					"1111000" WHEN "0111",
					"0000000" WHEN "1000",
					"0011000" WHEN "1001",
					"0001000" WHEN "1010",
					"0000011" WHEN "1011",
					"1000110" WHEN "1100",
					"0100001" WHEN "1101",
					"0000110" WHEN "1110",
					"0001110" WHEN "1111" ;  
  
end structural;
