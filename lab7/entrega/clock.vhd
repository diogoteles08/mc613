library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock is
  port (
    clk : in std_logic;
    decimal : in std_logic_vector(3 downto 0);
    unity : in std_logic_vector(3 downto 0);
    set_hour : in std_logic;
    set_minute : in std_logic;
    set_second : in std_logic;
    hour_dec, hour_un : out std_logic_vector(6 downto 0);
    min_dec, min_un : out std_logic_vector(6 downto 0);
    sec_dec, sec_un : out std_logic_vector(6 downto 0)
  );
end clock;

architecture rtl of clock is
  component clk_div is
    port (
      clk : in std_logic;
      clk_hz : out std_logic
    );
  end component;
  
  component bin2dec is
	port(
		SW: in std_logic_vector(3 downto 0);
		HEX0: out std_logic_vector(6 downto 0)
	);
	end component;
	
	signal clk_hz : std_logic;
	signal h_dec : std_logic_vector(3 downto 0) := "0000";
	signal h_un	: std_logic_vector(3 downto 0) := "0000";
	signal m_dec : std_logic_vector(3 downto 0) := "0000";
	signal m_un : std_logic_vector(3 downto 0) := "0000";
	signal s_dec : std_logic_vector(3 downto 0) := "0000";
	signal s_un: std_logic_vector(3 downto 0) := "0000";
	signal clk_hz_q: std_logic := '0';

begin

  clock_divider : clk_div port map (clk, clk_hz);
  hour_dec_7: bin2dec port map(h_dec, hour_dec);
  hour_un_7: bin2dec port map(h_un, hour_un);
  min_dec_7: bin2dec port map(m_dec, min_dec);
  min_un_7: bin2dec port map(m_un, min_un);
  sec_dec_7: bin2dec port map(s_dec, sec_dec);
  sec_un_7: bin2dec port map(s_un, sec_un);
  
  process (clk)
			variable h1_dec : std_logic_vector(3 downto 0) := "0000";
			variable h1_un	: std_logic_vector(3 downto 0) := "0000";
			variable m1_dec : std_logic_vector(3 downto 0) := "0000";
			variable m1_un : std_logic_vector(3 downto 0) := "0000";
			variable s1_dec : std_logic_vector(3 downto 0) := "0000";
			variable s1_un: std_logic_vector(3 downto 0) := "0000";
  begin
		if clk'EVENT and clk= '1' then
			clk_hz_q <= clk_hz;
			if set_hour = '1' then
				if decimal = "0010" and unity <= "0011" then
					h1_dec := decimal;
					h1_un := unity;
				elsif decimal < "0010" and unity <= "1001" then
					h1_dec := decimal;
					h1_un := unity;
				end if;			
			elsif set_minute = '1' then
				if decimal < "0110" and unity <= "1001" then
					m1_dec := decimal;
					m1_un := unity;
				end if;			
			elsif set_second = '1' then
				if decimal < "0110" and unity <= "1001" then
					s1_dec := decimal;
					s1_un := unity;
				end if;
			elsif clk_hz = '1' and clk_hz_q = '0' then
				s1_un := s1_un + "0001";
				if s1_un = "1010" then
					s1_un := "0000";
					s1_dec := s1_dec + "0001";
					if s1_dec = "0110" then
						s1_dec := "0000";
						m1_un := m1_un + "0001";
						if m1_un = "1010" then
							m1_un := "0000";
							m1_dec := m1_dec + "0001";
							if m1_dec = "0110" then
								m1_dec := "0000";
								h1_un := h1_un + "0001";
								if h1_un = "1010" then
									h1_un := "0000";
									h1_dec := h1_dec + "0001";
								elsif h1_dec = "0010" and h1_un = "0100" then
									h1_dec := "0000";
									h1_un := "0000";
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
		
		s_dec <= s1_dec;
		s_un <= s1_un;
		m_dec <= m1_dec;
		m_un <= m1_un;
		h_dec <= h1_dec;
		h_un <= h1_un;
  end process;
end rtl;