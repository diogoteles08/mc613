library ieee;
use ieee.std_logic_1164.all;

entity reg is
  generic (
    N : integer := 4
  );
  port (
    clock : in std_logic;
    DATA_IN : in std_logic_vector(N-1 downto 0);
    DATA_OUT : out std_logic_vector(N-1 downto 0);
    load : in std_logic; --write enable
    clear : in std_logic
  );
end reg;

architecture rtl of reg is

begin
  process(clock, clear) 
  begin
		IF clear = '0' THEN
			DATA_OUT <= "0000";		
		ELSIF clock'EVENT AND clock = '1' THEN
			IF load = '1' THEN
				DATA_OUT <= DATA_IN;
			END IF;
		END IF;
  end process;
end rtl;
