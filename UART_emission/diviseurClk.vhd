LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY diviseurClk IS
  -- facteur : ratio entre la fréquence de l'horloge origine et celle
  --           de l'horloge générée
  --  ex : 100 MHz -> 1Hz : 100 000 000
  --  ex : 100 MHz -> 1kHz : 100 000
  GENERIC (facteur : NATURAL);
  PORT (
    clk, reset : IN STD_LOGIC;
    nclk       : OUT STD_LOGIC);
END diviseurClk;

ARCHITECTURE arch_divClk OF diviseurClk IS

  SIGNAL top : STD_LOGIC := '0';

BEGIN

  div : PROCESS (clk, reset)
    VARIABLE cpt : INTEGER RANGE 0 TO facteur - 1 := 0;
  BEGIN
    IF reset = '0' THEN
      nclk <= '0';
      cpt := 0;
    ELSIF rising_edge(clk) THEN
      IF (cpt = facteur - 1) THEN
        cpt := 0;
      ELSE
        cpt := cpt + 1;
      END IF;
      IF cpt = 0 THEN
        nclk <= '1';
      ELSE
        nclk <= '0';
      END IF;
    END IF;
  END PROCESS;

END arch_divClk;
