library ieee;
use ieee.std_logic_1164.all;

entity reg is
  generic (
    N : integer := 32
  );
  port (
    clock : in std_logic;
    datain : in std_logic_vector(N-1 downto 0);
    dataout : out std_logic_vector(N-1 downto 0);
    load : in std_logic; --write enable
    clear : in std_logic
  );
end reg;

architecture rtl of reg is

begin
  process(clock, clear) 
  begin
		IF clear = '0' THEN
			dataout <= (others => '0');		
		ELSIF clock'EVENT AND clock = '1' THEN
			IF load = '1' THEN
				dataout <= datain;
			END IF;
		END IF;
  end process;
end rtl;
