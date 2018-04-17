library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
generic (N : integer := 6);
port(
    clk     : in  std_logic;
    mode    : in  std_logic_vector(1 downto 0);
    ser_in  : in  std_logic;
    par_in  : in  std_logic_vector((N - 1) downto 0);
    par_out : out std_logic_vector((N - 1) downto 0)
  );
end shift_register;

architecture rtl of shift_register is
begin
  process ( clk )
		variable temp : std_logic_vector((N-1) downto 0);
  begin
		if clk'EVENT and clk = '1' then
			if mode = "01" then
				temp := temp((N-2) downto 0) & ser_in;
			elsif mode = "10" then
				temp := ser_in & temp((N-1) downto 1);
			elsif mode = "11" then
				temp := par_in;
			end if;
		end if;
		par_out <= temp;
  end process;
end rtl;
