library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use std.env.all;

library work;

entity testbench is
end testbench;

architecture behave of testbench is
  signal WR_EN     : std_logic;
  signal RD_EN     : std_logic;
  signal clear     : std_logic;
  signal clock     : std_logic;
  signal WR_ADDR   : std_logic_vector ( 4 downto 0);
  signal RD_ADDR1  : std_logic_vector ( 4 downto 0);
  signal RD_ADDR2  : std_logic_vector ( 4 downto 0);
  signal DATA_IN   : std_logic_vector (31 downto 0);
  signal DATA_OUT1 : std_logic_vector (31 downto 0);
  signal DATA_OUT2 : std_logic_vector (31 downto 0);
begin

  bank_inst : entity work.bank port map (
    WR_EN     => WR_EN     ,
    RD_EN     => RD_EN     ,
    clear     => clear     ,
    clock     => clock     ,
    WR_ADDR   => WR_ADDR   ,
    RD_ADDR1  => RD_ADDR1  ,
    RD_ADDR2  => RD_ADDR2  ,
    DATA_IN   => DATA_IN   ,
    DATA_OUT1 => DATA_OUT1 ,
    DATA_OUT2 => DATA_OUT2
  );

  process
    file file_in  : text;
    file file_out : text;

    variable v_space   : character;
    variable v_rd_line : line;
    variable v_wr_line : line;

    variable v_WR_EN     : std_logic;
    variable v_RD_EN     : std_logic;
    variable v_clear     : std_logic;
    variable v_clock     : std_logic;
    variable v_WR_ADDR   : std_logic_vector ( 4 downto 0);
    variable v_RD_ADDR1  : std_logic_vector ( 4 downto 0);
    variable v_RD_ADDR2  : std_logic_vector ( 4 downto 0);
    variable v_DATA_IN   : std_logic_vector (31 downto 0);
  begin

    file_open(file_in , "vector_input.txt" , read_mode);
    file_open(file_out, "vector_output.txt", write_mode);

    while not endfile(file_in) loop
      readline(file_in, v_rd_line);

      read(v_rd_line, v_clock    ); read(v_rd_line, v_space);
      read(v_rd_line, v_clear    ); read(v_rd_line, v_space);
      read(v_rd_line, v_WR_EN    ); read(v_rd_line, v_space);
      read(v_rd_line, v_RD_EN    ); read(v_rd_line, v_space);
      read(v_rd_line, v_WR_ADDR  ); read(v_rd_line, v_space);
      read(v_rd_line, v_RD_ADDR1 ); read(v_rd_line, v_space);
      read(v_rd_line, v_RD_ADDR2 ); read(v_rd_line, v_space);
      read(v_rd_line, v_DATA_IN  );

      clock    <= v_clock    ;
      clear    <= v_clear    ;
      WR_EN    <= v_WR_EN    ;
      RD_EN    <= v_RD_EN    ;
      WR_ADDR  <= v_WR_ADDR  ;
      RD_ADDR1 <= v_RD_ADDR1 ;
      RD_ADDR2 <= v_RD_ADDR2 ;
      DATA_IN  <= v_DATA_IN  ;

      write(v_wr_line, DATA_OUT1);
      write(v_wr_line, string'(" "));
      write(v_wr_line, DATA_OUT2);
      writeline(file_out, v_wr_line);

      wait for 1ns;
    end loop;

    file_close(file_in);
    file_close(file_out);

    finish(0);

  end process;

end behave;
