LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE mM_pack IS
	component ram is
		generic(
			depth : natural := 12;
			width: natural := 32;
			init_file : string := ""
		);
		port(
			clk : in std_logic;
			memwrite:  in std_logic;
			ra, wa : in std_logic_vector(depth-1 downto 0);
			writedata : in std_logic_vector(width-1 downto 0);
			memdata : out std_logic_vector(width-1 downto 0)
		);
	end component;
	
	component rom is
		generic (
			depth : natural   := 32;
			width : natural   := 32; 
			init_file : string := ""
		);
		port(
		  clk : in std_logic;
		  adr: in std_logic_vector(depth-1 downto 0);
		  memdata: out std_logic_vector(width-1 downto 0)
	    );
	end component;
	
	component vga_text_mode is
		generic (
			init_file1 : string := "";
			init_file2 : string := ""
		);	
		port(
			clk : in std_logic;
			reset : in std_logic;
			write: in std_logic_vector(1 downto 0);
			showmem : in std_logic;
			wa : in std_logic_vector(11 downto 0);
			wd : in std_logic_vector(7 downto 0);
			HS : out std_logic;
			VS : out std_logic;
			blank : out std_logic;
			column : out std_logic_vector(6 downto 0);
			row : out std_logic_vector(5 downto 0);
			pixel : out std_logic
		);
	end component;
	
	component vga_timing is
		port(
			clk : in std_logic;
			reset : in std_logic;
			HS : out std_logic;
			VS : out std_logic;
			pixel_x : out std_logic_vector(9 downto 0);
			pixel_y : out std_logic_vector(9 downto 0);
			last_column : out std_logic;
			last_row : out std_logic;
			blank : out std_logic
		);
	end component;
	
	component flopar is
		generic(
			width: natural := 32
		);
		port(
			clk, reset: in std_logic;
			d: in  std_logic_vector(width-1 downto 0);
			q: out std_logic_vector(width-1 downto 0)
		);
	end component;
	
	component bin2hexascii is
		port(
			bin   : in std_logic_vector(3 downto 0);
			ascii : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component m1ps2vga is
		port(
			clk : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			pc, ir, dbus, rs1, rs2 : in std_logic_vector(31 downto 0); 
			stat : in std_logic_vector(3 downto 0);
			pcld, pcinc, irwr, regwr, statwr, dmwr, dmrd, dm2dbus,
				alu2dbus, reg2io, io2reg : in std_logic;
			aluop : in std_logic_vector(1 downto 0);
			memdata : in std_logic_vector(31 downto 0);
			regdata : in std_logic_vector(31 downto 0);
			
			vgawrite : out std_logic_vector(1 downto 0);
			vgawa : out std_logic_vector(11 downto 0);
			vgawd : out std_logic_vector(7 downto 0);
			memraddr : out std_logic_vector(7 downto 0);
			regaddr : out std_logic_vector(4 downto 0)
		);
	end component;
	
	component freqdiv is
		generic (DIV : natural := 2);
		port (
			clk : in std_logic;
			reset : in std_logic;
			clk_out : out std_logic
		);
	end component;
	
	component monitor is
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
	end component;
	
	component counter is
		generic (
			nmax : natural := 128
		);
		port(	
			clk : in std_logic;
			reset : in std_logic;
			recount : in std_logic;
			encount : in std_logic;
			n : out natural range 0 to nmax;
			onmax : out std_logic
		);
	end component;
  
  component bin2hex is
  port(
      SW  : in std_logic_vector(3 downto 0);
      HEX0: out std_logic_vector(6 downto 0)
    );
  end component;
	
END PACKAGE;
