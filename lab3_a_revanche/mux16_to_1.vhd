library ieee;
use ieee.std_logic_1164.all;

entity mux16_to_1 is
  port(data : in std_logic_vector(15 downto 0);
       sel : in std_logic_vector(3 downto 0);
       output : out std_logic);
end mux16_to_1;

architecture rtl of mux16_to_1 is
begin
  -- add your code
end rtl;

