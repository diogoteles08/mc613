library ieee;
use ieee.std_logic_1164.all;

entity bin2hexascii is
  port (bin   : in std_logic_vector(3 downto 0);
        ascii : out std_logic_vector(7 downto 0));
end bin2hexascii;

architecture behavior of bin2hexascii is
begin
  with bin select 
    ascii    <= x"30" when "0000", --zero
                x"31" when "0001", --um
                x"32" when "0010", --dois
                x"33" when "0011", --tres
                x"34" when "0100", --quarto
                x"35" when "0101", --cinco
                x"36" when "0110", --seis
                x"37" when "0111", --sete
                x"38" when "1000", --oito
                x"39" when "1001", --nove
                x"41" when "1010", --a
                x"42" when "1011", --b
                x"43" when "1100", --c
                x"44" when "1101", --d
                x"45" when "1110", --e
                x"46" when "1111"; --f
end behavior;