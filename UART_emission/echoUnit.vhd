LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY echoUnit IS
  PORT (
    clk, reset : IN STD_LOGIC;
    cs, rd, wr : OUT STD_LOGIC;
    IntR       : IN STD_LOGIC; -- interruption de réception
    IntT       : IN STD_LOGIC; -- interruption d'émission
    addr       : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    data_in    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_out   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END echoUnit;

ARCHITECTURE echoUnit_arch OF echoUnit IS

  TYPE t_etat IS (test_emission, attente, reception, attente_emission, pret_a_emettre, emission);
  SIGNAL etat   : t_etat                       := attente;
  SIGNAL donnee : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

BEGIN

  PROCESS (clk, reset)
  BEGIN

    IF reset = '0' THEN

      etat <= test_emission;

    ELSIF rising_edge(clk) THEN

      CASE etat IS

          -- cet état n'est destiné qu'à tester l'émission
        WHEN test_emission =>
          cs       <= '1';
          rd       <= '1';
          wr       <= '1';
          data_out <= (OTHERS => '0');
          addr     <= (OTHERS => '0');
          -- donnée = caractère A (0x41) (poids faibles d'abord)
          donnee <= "10000010";
          etat   <= pret_a_emettre;

        WHEN attente =>
          cs       <= '1';
          rd       <= '1';
          wr       <= '1';
          data_out <= (OTHERS => '0');
          addr     <= (OTHERS => '0');
          IF (IntR = '0') THEN
            -- IntR=0 -> une nouvelle donnée est reçue
            -- on la lit
            etat <= reception;
            cs   <= '0';
            rd   <= '0';
            wr   <= '1';
          END IF;

        WHEN reception =>
          donnee <= data_in;
          IF (IntR = '1') THEN
            -- la donnée est lue
            addr <= "00";
            etat <= attente_emission;
          END IF;

        WHEN attente_emission =>
          cs   <= '1';
          rd   <= '1';
          wr   <= '1';
          etat <= pret_a_emettre;

        WHEN pret_a_emettre =>
          -- pour savoir si l'unité d'émission est prête
          -- on teste le registre de contrôle
          cs   <= '0';
          rd   <= '0';
          wr   <= '1';
          addr <= "01";
          -- le bit 3 correspond à TxRdy = 1
          IF data_in(3) = '1' THEN
            cs   <= '1';
            rd   <= '1';
            wr   <= '1';
            etat <= emission;
          END IF;

        WHEN emission =>
          -- on écrit la donnée dans le buffer d'émission
          cs       <= '0';
          rd       <= '1';
          wr       <= '0';
          data_out <= donnee;
          donnee   <= (OTHERS => '0');
          etat     <= attente;

      END CASE;
    END IF;
  END PROCESS;

END echoUnit_arch;
