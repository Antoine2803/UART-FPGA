LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ctrlUnit IS

  PORT (
    clk, reset       : IN STD_LOGIC;
    rd, cs           : IN STD_LOGIC;
    DRdy, FErr, OErr : IN STD_LOGIC;
    BufE, RegE       : IN STD_LOGIC;
    IntR             : OUT STD_LOGIC;
    IntT             : OUT STD_LOGIC;
    ctrlReg          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

END ctrlUnit;

ARCHITECTURE ctrlUnit_arch OF ctrlUnit IS

  SIGNAL registreC : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

  ctrlReg <= registreC WHEN (rd = '0' AND cs = '0') ELSE
    "11110000";

  ctrlProcess : PROCESS (clk, reset)

  BEGIN
    IF reset = '0' THEN

      IntR      <= '1';
      IntT      <= '1';
      registreC <= "11110000";

    ELSIF clk'event AND clk = '1' THEN

      IF DRdy = '0' THEN
        IntR         <= '1';
        registreC(2) <= '0';
      ELSIF DRdy = '1' AND FErr = '0' AND OErr = '0' THEN
        IntR         <= '0';
        registreC(2) <= '1';
      END IF;

      IF (BufE = '1' OR RegE = '1') THEN
        IntT         <= '0';
        registreC(3) <= '1';
      ELSE
        IntT         <= '1';
        registreC(3) <= '0';
      END IF;

      registreC(1) <= FErr;
      registreC(0) <= OErr;

    END IF;

  END PROCESS ctrlProcess;

END ctrlUnit_arch;
