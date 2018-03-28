library ieee;
use ieee.std_logic_1164.all;

entity adder is
  port (
    x, y : in std_logic;
    r : out std_logic;
    cin : in std_logic    
  );
end adder;

architecture structural of adder is
begin
  r <= x XOR y XOR cin;  
end structural;
