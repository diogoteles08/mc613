library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

package word_base is
	constant words_by_num_letter: integer := 4;
	
	type word_arr is array(integer range 0 to words_by_num_letter-1) of string(max_word_length downto 1);
	type word_base_t is array (integer range min_word_length to max_word_length) of word_arr;

	-- ONLY UPPER CASE
	constant word_base: word_base_t :=
	 (
	 (
"[[[[[[[[OG",
"[[[[[[[[CM",
"[[[[[[[[EF",
"[[[[[[[[AL"
    ),
    (
"[[[[[[[AUL",
"[[[[[[[PHP",
"[[[[[[[TIG",
"[[[[[[[ADA"
    ),
    (
"[[[[[[LDHV",
"[[[[[[AVAJ",
"[[[[[[ORIC",
"[[[[[[PSIL"
    ),
    (
"[[[[[LLEHS",
"[[[[[ODIUG",
"[[[[[CISAB",
"[[[[[AILUJ",
    ),
    (
"[[[[NOHTYP",
"[[[[LEKSAH",
"[[[[NARTOF",
"[[[[EVATCO"
    ),
    (
"[[[GOLIREV",
"[[[IKAAKAT",
"[[[ODLANRA",
"[[[ENIHCAM"
    ),
    (
"[[YLBMESSA",
"[[ENIAVILO",
"[[SAIRACAZ",
"[[ENILEPIP"
    ),
    (
"[RAMARGORP",
"[SOLELARAP",
"[KLATLLAMS",
"[ELBATHSAH",
    ),
    (
"CEVITCEJBO",
"TPIRCSAVAJ",
"ORIETUPMOC",
"TSILDEKNIL"
    ) 	
	);
end word_base;
