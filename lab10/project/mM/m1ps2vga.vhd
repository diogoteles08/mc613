library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library mM;
use mM.mM_pack.all;

entity m1ps2vga is
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
end m1ps2vga;

architecture a_m1ps2vga of m1ps2vga is
    type state_type is (IDLE, SIGNALCOPY, REGFETCH, REGCOPY, GENERALCOPY, MEMFETCH, MEMCOPY);
    
    signal y, y_next : state_type;
    signal ctrl : std_logic_vector(0 to 12);
    signal general : std_logic_vector(159 downto 0);
    signal bin : std_logic_vector(3 downto 0);
    signal vvgawa : std_logic_vector(11 downto 0);
    signal vvgawd : std_logic_vector(7 downto 0);
    signal vvgawrite : std_logic_vector(1 downto 0);
	signal gword : std_logic_vector(31 downto 0);
    
    signal i : natural range 0 to 26;
    signal j : natural range 0 to 8;
    signal k : natural range 0 to 7;
    
    signal i_recount, i_encount, j_recount, j_encount, k_recount,
		k_encount : std_logic;
    
begin
    
    -- decoding binary to hexadecimal characters
	DECODER: bin2hexascii
		port map(bin, vvgawd);
	
	-- counters	
	COUNTER_I: counter
		generic map(26)
		port map(clk, reset, i_recount, i_encount, i);
	
	COUNTER_J: counter
		generic map(8)
		port map(clk, reset, j_recount, j_encount, j);
		
	COUNTER_K: counter
		generic map(7)
		port map(clk, reset, k_recount, k_encount, k);	
    
    -- control signals
    ctrl <= pcld & pcinc & irwr & regwr & statwr & dmwr & dmrd & dm2dbus &
			alu2dbus & reg2io & io2reg & aluop(1) & aluop(0);
            
    -- general signals
    general <= rs2 & rs1 & dbus & ir & pc; 
    
    -- changing state
    process (clk, reset)
    begin  
		if reset = '1' then
			y <= IDLE;
        elsif clk'event and clk = '1' then
            y <= y_next;
        end if;
    end process;
    
    -- choosing state
    process (start, y, ctrl, general, regdata, memdata, stat, i, j, k, gword)
    begin
		bin <= (others => '-');
		vvgawa <= (others => '-');
		regaddr <= (others => '-');
		memraddr <= (others => '-');
		gword <= (others => '-');
		i_recount <= '0';
		j_recount <= '0';
		k_recount <= '0';
		i_encount <= '0';
		j_encount <= '0';
		k_encount <= '0';
		vvgawrite <= "00";
		y_next <= y;
        case y is
            when IDLE =>
				i_recount <= '1';
				j_recount <= '1';
				k_recount <= '1';
                if start = '1' then
                    y_next <= SIGNALCOPY;
                end if;
            when SIGNALCOPY =>
                vvgawa <= std_logic_vector(to_unsigned((8 + i)*128 + 9 + 23*j + k, 12)); 
                bin <= "000" & ctrl(j*4 + i + k);
                vvgawrite <= "01";
				i_encount <= '1';
				if k = 1 then
					i_recount <= '1';
					j_recount <= '1';
					k_recount <= '1';
					y_next <= REGFETCH;	
                elsif i = 3 then
                    i_recount <= '1';
					j_encount <= '1';
                    if j = 2 then
						i_encount <= '0';
						j_encount <= '0';
						k_encount <= '1';
						i_recount <= '0';
					else 
                    end if;
                end if;
            when REGFETCH =>
				regaddr <= std_logic_vector(to_unsigned(j*8+i, 5)); 
                y_next <= REGCOPY;
                k_recount <= '1';
                if i = 8 then
                    i_recount <= '1';
                    j_encount <= '1';
                    if j = 3 then
                        j_recount <= '1';
                        y_next <= GENERALCOPY;
                    end if;
                end if;
            when REGCOPY =>
                vvgawa <= std_logic_vector(to_unsigned((14 + i)*128 + 5 + 19*j + k, 12));
                bin <= regdata((7-k)*4 + 3 downto (7-k)*4);
                vvgawrite <= "01";
                k_encount <= '1';
                if k = 7 then
					i_encount <= '1';
                    y_next <= REGFETCH;
                end if;
            when GENERALCOPY =>
                vvgawa <= std_logic_vector(to_unsigned((3 + i)*128 + 7 + 17*j + k, 12));
                gword <= general((j*3 + i)*32 + 31  downto (j*3 + i)*32);
				bin <= gword((7-k)*4 + 3 downto (7-k)*4);
                vvgawrite <= "01";
                k_encount <= '1';
                if i = 2 and j = 1 then
					i_recount <= '1';
					j_recount <= '1';
					bin <= stat;
					y_next <= MEMFETCH;
				elsif k = 7 then
                    i_encount <= '1';
                    k_recount <= '1';
                    if i = 2 then
                        i_recount <= '1';
                        j_encount <= '1';
                    end if;
                end if;
            when MEMFETCH =>
				memraddr <= std_logic_vector(to_unsigned(i*8 + j, 8));
				y_next <= MEMCOPY;
				k_recount <= '1';
				if j = 8 then
					j_recount <= '1';
					i_encount <= '1';
					if i = 26 then
						i_recount <= '1';
						y_next <= IDLE;
					end if;
				end if;
			when MEMCOPY =>
				vvgawa <= std_logic_vector(to_unsigned((3 + i)*128 + 6 + 9*j + k, 12));
				bin <= memdata((7-k)*4+3 downto (7-k)*4);
				vvgawrite <= "10";
				k_encount <= '1';
				if k = 7 then
					y_next <= MEMFETCH;
					j_encount <= '1';
				end if;
        end case;
    end process;
	
	-- driving outputs
	vgawa <= vvgawa;
	vgawd <= vvgawd;
	vgawrite <= vvgawrite;
    
	

end a_m1ps2vga;