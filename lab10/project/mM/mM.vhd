library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Processor;
use Processor.Processor_pack.all;

library mM;
use mM.mM_pack.all;

-- wordsize: 32 bits
-- mem address bits: 8 bits (256 words)
-- two screens
entity monitor is
	generic(
		dm_init : string := ""
	);
	port(
		clk  : in std_logic;
		reset : in std_logic;
		pc, ir, dbus, rs1, rs2 : in std_logic_vector(31 downto 0);
		stat : in std_logic_vector(3 downto 0);
		pcld, pcinc, irwr, regwr, statwr, dmwr, dmrd, dm2dbus,
			alu2dbus, reg2io, io2reg : in std_logic;
		aluop : in std_logic_vector(1 downto 0);
		showscreen : in std_logic;
		vgaHS, vgaVS, vgablank, vgapixel : out std_logic;
		vgacolumn : out std_logic_vector(6 downto 0);
		vgarow : out std_logic_vector(5 downto 0)
	);
end monitor;

architecture a_monitor of monitor is
	
	-- SHADOW RAM's signals
	signal memraddr : std_logic_vector(7 downto 0);
	signal memdata : std_logic_vector(31 downto 0);

	-- SHADOW BANK's signals
	signal regaddr : std_logic_vector(4 downto 0);
	signal regdata : std_logic_vector(31 downto 0);
	
	-- VGA's signals
	signal vgawrite : std_logic_vector (1 downto 0);
	signal vgawa : std_logic_vector(11 downto 0);
	signal vgawd : std_logic_vector(7 downto 0);
	
begin

	SHADOW_RAM: ram
		generic map(8, 32, dm_init)
		port map(clk, dmwr, memraddr, rs1(7 downto 0), rs2, memdata);
		
	SHADOW_BANK: bank
		generic map(32)
		port map(regwr, '1', reset, clk, ir(25 downto 21), regaddr, 
			(others => '0'), dbus, regdata);
	
	VGA_CONTROL: vga_text_mode
		generic map("layout_geral.mif", "layout_mem.mif")
		port map(clk, reset, vgawrite, showscreen, vgawa, vgawd, 
			vgaHS, vgaVS, vgablank, vgacolumn, vgarow, vgapixel);
			
	m1ps_2_VGA: m1ps2vga
	port map(clk, reset, '1', pc, ir, dbus, rs1, rs2, stat, pcld, pcinc, irwr, regwr, statwr, dmwr, 
		dmrd, dm2dbus, alu2dbus, reg2io, io2reg, aluop, memdata, regdata, vgawrite, 
		vgawa, vgawd, memraddr, regaddr);
			
end a_monitor;
