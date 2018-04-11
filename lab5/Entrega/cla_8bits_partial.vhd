-- brief : lab05 - question 2

library ieee;
use ieee.std_logic_1164.all;

entity cla_8bits_partial is
  port(
    x    : in  std_logic_vector(7 downto 0);
    y    : in  std_logic_vector(7 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(7 downto 0);
    cout : out std_logic
  );
end cla_8bits_partial;

architecture rtl of cla_8bits_partial is
	component cla_4bits
	port(
    x    : in  std_logic_vector(3 downto 0);
    y    : in  std_logic_vector(3 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(3 downto 0);
    cout : out std_logic
  );
	end component;

	signal c_out_aux : std_logic;
begin
  
  first_cla_4: cla_4bits port map (
		x => x(3 downto 0),
		y => y(3 downto 0),
		cin => cin,
		sum => sum(3 downto 0),
		cout => c_out_aux
  );
  
  second_cla_4: cla_4bits port map (
		x => x(7 downto 4),
		y => y(7 downto 4),
		cin => c_out_aux,
		sum => sum(7 downto 4),
		cout => cout
  );
  
end rtl;