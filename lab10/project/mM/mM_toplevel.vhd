library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Processor;
use Processor.Processor_pack.all;

library mM;
use mM.mM_pack.all;

entity mM_toplevel is
	port(
		CLOCK_50 : in std_logic;
		KEY : in std_logic_vector(3 downto 0);
		SW : std_logic_vector(9 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_R : out std_logic_vector(7 downto 0);
		VGA_G : out std_logic_vector(7 downto 0);
		VGA_B : out std_logic_vector(7 downto 0);
    VGA_BLANK_N, VGA_SYNC_N : OUT STD_LOGIC;
		VGA_CLK : OUT STD_LOGIC;
		LEDR : out std_logic_vector(9 downto 0);
    HEX5,HEX4,HEX3,HEX2,HEX1,HEX0 : out std_logic_vector(6 downto 0)
	);
end mM_toplevel;

architecture a_mM_toplevel of mM_toplevel is
		signal clk, reset, mclk, pcld, pcinc, irwr, statwr, dmwr, dmrd, dm2dbus,
			alu2dbus, reg2io, io2reg, regwr, vgablank, vgapixel, vgaHS, vgaVS: std_logic;
			
		signal pc, ir, dbus, rs1, rs2 : std_logic_vector(31 downto 0);
		signal stat : std_logic_vector(3 downto 0);
    
    signal io_out, io_in : std_logic_vector(31 downto 0);
		
    signal slow,slowest : std_logic;
begin
	reset <= not KEY(3);
	mclk <= not slowest when KEY(1) = '0' else slow when KEY(2) = '0' else NOT KEY(0);
  LEDR <= (others => '0');
  
  io_in <= x"000000" & SW(7 downto 0);
  
  disp5: bin2hex port map (io_out(23 downto 20), HEX5);
  disp4: bin2hex port map (io_out(19 downto 16), HEX4);
  disp3: bin2hex port map (io_out(15 downto 12), HEX3);
  disp2: bin2hex port map (io_out(11 downto 8), HEX2);
  disp1: bin2hex port map (io_out(7 downto 4), HEX1);
  disp0: bin2hex port map (io_out(3 downto 0), HEX0);
  
  VGA_BLANK_N <= '1';
  VGA_SYNC_N <= '0';
  VGA_CLK <= clk;
	
	CLOCKDIVISOR: freqdiv
		generic map(1)
		port map(CLOCK_50, reset, clk);
    
  SLOW_CLOCK: freqdiv generic map (2500000) port map(CLOCK_50,reset,slow);
  SLOWEST_CLOCK: freqdiv generic map (12500000) port map(CLOCK_50,reset,slowest);

	m1ps_Monitor: monitor
	generic map("dmemory.mif")
		port map(clk, reset, pc, ir, dbus, rs1, rs2, stat, pcld, pcinc, irwr, regwr, statwr, dmwr, dmrd, dm2dbus,
			alu2dbus, reg2io, io2reg, ir(27 downto 26), SW(9), vgaHS, vgaVS, vgablank, vgapixel);
			
	m1ps: CPU
		port map  (
			clock => mclk,
			reset => reset,
			IO_IN => io_in,
			DBus => dbus,
			RSource1 => rs1,			
			RSource2 => rs2, 			
			IO_OUT => io_out,
			IM_address => pc,			
			-- IM_instruction_out => ,	
			instruction => ir,			
			stat_CVNZ => stat,	
			Pc_Ld	=> pcld,	
			IR_Ld	=> irwr,		
			Pc_Inc	=> pcinc,			
			ALU_2_DBus	=> alu2dbus,		
			DM_Rd => dmrd,				
			DM_Wr => dmwr,				
			-- PC_Ld_En ,		
			Reg_2_IO => reg2io,			
			IO_2_Reg => io2reg,	
			Reg_Wr	=> regwr,			
			Stat_Wr	=> statwr,			
			DM_2_DBus => dm2dbus		
		);
		
	VGA_R <= (others => '0');
	VGA_B <= (others => '0');
	VGA_G(3 downto 0) <= (others => '0');
	process(clk, reset)
	begin
		if reset = '1' then
			VGA_G(7 downto 4) <= (others => '0');
		elsif clk'event and clk = '1' then
			VGA_HS <= vgaHS;
			VGA_VS <= vgaVS;
			VGA_G(7 downto 4) <= (others => '0');
			if vgablank = '0' then
				VGA_G(7 downto 4) <= (others => vgapixel);	
			end if;
		end if;
	end process;
		
end a_mM_toplevel;
