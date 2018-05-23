LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory IS
  GENERIC (
    WORDSIZE    : NATURAL := 32;
    BITS_OF_ADDR  : NATURAL := 10;
    MIF_FILE    : STRING  := "memory.mif"
  );
  PORT (
    clock   : IN  STD_LOGIC;
    we      : IN  STD_LOGIC;
    address : IN  STD_LOGIC_VECTOR(BITS_OF_ADDR-1 DOWNTO 0);
    datain  : IN  STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
    dataout : OUT STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE RTL OF memory IS
  TYPE ram_type IS ARRAY ((2**BITS_OF_ADDR)-1 DOWNTO 0) OF STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
  
  SIGNAL ram      : ram_type;
  SIGNAL read_address : STD_LOGIC_VECTOR(BITS_OF_ADDR-1 DOWNTO 0);
  
  ATTRIBUTE ram_init_file     : STRING;
  ATTRIBUTE ram_init_file OF ram  : SIGNAL IS MIF_FILE; 
BEGIN
  MemoryProc: PROCESS(clock) IS
  BEGIN
    IF (RISING_EDGE(clock)) THEN
      IF we = '1' THEN
        ram(TO_INTEGER(UNSIGNED(address))) <= datain;
      END IF;
      read_address  <= address;
    END IF;
  END PROCESS;
  dataout <= ram(TO_INTEGER(UNSIGNED(read_address)));
end architecture RTL;

