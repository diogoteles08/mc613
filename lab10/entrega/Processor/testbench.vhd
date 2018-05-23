library ieee;
use ieee.std_logic_1164.all;

library work;

entity testbench is
end testbench;

architecture rtl of testbench is
  signal clock : std_logic := '0';
  signal reset : std_logic := '1';
  signal IO_IN : std_logic_vector(31 downto 0) := (others => '0');
begin

  CPU_inst : entity work.CPU port map (
    clock              => clock,
    reset              => reset,
    IO_IN              => IO_IN,
    Pc_Ld              => open,
    IR_Ld              => open,
    Pc_Inc             => open,
    ALU_2_DBus         => open,
    DM_Rd              => open,
    DM_Wr              => open,
    PC_Ld_En           => open,
    Reg_2_IO           => open,
    IO_2_Reg           => open,
    Reg_Wr             => open,
    Stat_Wr            => open,
    DM_2_DBus          => open,
    DBus               => open,
    IM_address         => open,
    IM_instruction_out => open,
    instruction        => open,
    IO_OUT             => open,
    RSource1           => open,
    RSource2           => open,
    stat_CVNZ          => open
  );

  clock <= not clock after 1 ns;

  process
  begin
    reset <= '0';

    wait until rising_edge(clock);

    reset <= '1';

    for count_value in 1 to 4 loop
      wait until rising_edge(clock);
    end loop;

    reset <= '0';

    for count_value in 1 to 5 loop
      IO_in <= x"00000008";
      wait until rising_edge(clock);
    end loop;

    for count_value in 1 to 3 loop
      IO_in <= x"00000000";
      wait until rising_edge(clock);
    end loop;

    for count_value in 1 to 4 loop
      IO_in <= x"00000001";
      wait until rising_edge(clock);
    end loop;

    for count_value in 1 to 3 loop
      IO_in <= x"00000040";
      wait until rising_edge(clock);
    end loop;

    wait;
  end process;

end rtl;
