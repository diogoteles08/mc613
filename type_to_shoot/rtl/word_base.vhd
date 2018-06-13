library ieee;
library work;
use ieee.std_logic_1164.all;
use work.main_pack.all;

package word_base is
	constant words_by_num_letter: integer := 5;
	
	type word_arr is array(integer range 0 to words_by_num_letter-1) of string(max_word_length downto 1);
	type word_base_t is array (integer range min_word_length to max_word_length) of word_arr;

	-- ONLY UPPER CASE
	constant word_base: word_base_t :=
	 (
	 (
"[[[[[[[[OG",
"[[[[[[[[CM",
"[[[[[[[[EF",
"[[[[[[[[CP",
"[[[[[[[[SL"
    ),
    (
"[[[[[[[AUL",
"[[[[[[[PHP",
"[[[[[[[TIG",
"[[[[[[[ADA",
"[[[[[[[MIV"
    ),
    (
"[[[[[[LDHV",
"[[[[[[AVAJ",
"[[[[[[ORIC",
"[[[[[[PSIL",
"[[[[[[ODUS"
    ),
    (
"[[[[[LLEHS",
"[[[[[ODIUG",
"[[[[[CISAB",
"[[[[[AILUJ",
"[[[[[TIDEG"
    ),
    (
"[[[[NOHTYP",
"[[[[LEKSAH",
"[[[[NARTOF",
"[[[[EVATCO",
"[[[[LACSAP"
    ),
    (
"[[[GOLIREV",
"[[[IKAAKAT",
"[[[ODLANRA",
"[[[ENIHCAM",
"[[[UAHCTAK"
    ),
    (
"[[YLBMESSA",
"[[ENIAVILO",
"[[SAIRACAZ",
"[[ENILEPIP",
"[[GNINRAEL"
    ),
    (
"[RAMARGORP",
"[SOLELARAP",
"[KLATLLAMS",
"[ELBATHSAH",
"[ACILLATEM"
    ),
    (
"CEVITCEJBO",
"TPIRCSAVAJ",
"ORIETUPMOC",
"TSILDEKNIL",
"RODALIPMOC"
    ) 	 	
	);
end word_base;
