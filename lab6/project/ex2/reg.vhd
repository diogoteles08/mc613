library ieee;
use ieee.std_logic_1164.all;

entity reg is
  generic (
    N : integer := 4
  );
  port (
    clk : in std_logic;
    data_in : in std_logic_vector(N-1 downto 0);
    data_out : out std_logic_vector(N-1 downto 0);
    load : in std_logic;
    clear : in std_logic
  );
end reg;

architecture rtl of reg is

begin
  process(clk, clear) 
  begin
		IF clear = '1' THEN
			data_out <= "0000";		
		ELSIF Clk'EVENT AND Clk = '1' THEN
			IF load = '1' THEN
				data_out <= data_in;
			END IF;
		END IF;
  end process;
end rtl;
