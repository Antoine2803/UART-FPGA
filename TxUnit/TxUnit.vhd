library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is
	type tetat is (IDLE, INIT, SENDINIT, SENDING, SENDEND);
	signal bufferT : std_logic_vector(7 downto 0);
	signal registerT : std_logic_vector(7 downto 0);
	signal etat : tetat := IDLE;
begin
	process(clk,reset)
		variable cpt_bit : natural := 8;
		variable parite : std_logic;
		
		-- Variable interne correspondant au signal bufE 
		-- permettant de tester sa valeur. (car bufE en out)
		variable internalBufE : std_logic; 
	begin
		if (reset = '0') then
			-- Initialisation des variables lors du reset.
			bufferT <= (others => '0');
			registerT <= (others => '0');
			parite := '0';
			cpt_bit := 8;
			regE <= '1';
			internalBufE := '1';
			bufE <= internalBufE;
			txd <= '1';
			etat <= IDLE;
		elsif (rising_edge(clk)) then
			case etat is
				when IDLE =>
					if (ld = '1') then
						-- Initialisation des variables.
						registerT <= (others => '0');
						bufferT <= (others => '0');
						bufferT <= data;
						internalBufE := '0';
						bufE <= internalBufE;
						parite := '0';
						regE <= '1';
						etat <= INIT;
					end if;
				
				when INIT =>
					-- Mise en place des buffers.
					registerT <= bufferT;
					regE <= '0';
					internalBufE := '1';
					bufE <= internalBufE;
					parite := '0';
					etat <= SENDINIT;
				
				when SENDINIT => 
					-- Initalisation des variables et signaux
					-- pour préparer l'envoi.
					if (enable = '1') then
						txd <= '0';
						cpt_bit := 8;
						etat <= SENDING;
					end if;
					
					-- Réception pour reémision direct
					if (ld = '1' and internalBufE = '1') then
						bufferT <= data;
						internalBufE := '0';
						bufE <= internalBufE;
					end if;					
					
				when SENDING =>
					-- Envoi.
					if (enable = '1' and cpt_bit > 0) then
						-- Envoi des bits du registre de tansmission
						-- un par un et calcul au fur et à mesure du
						-- bit de parité.
						cpt_bit := cpt_bit - 1;
						txd <= registerT(cpt_bit);
						parite := parite xor registerT(cpt_bit);
					elsif (enable = '1' and cpt_bit = 0) then
						-- Envoi de data terminé, on envoi alors le bit
						-- de parité.
						txd <= parite;
						etat <= SENDEND;
					end if;
					
					-- Réception pour reémision direct
					if (ld = '1' and internalBufE = '1') then
						bufferT <= data;
						internalBufE := '0';
						bufE <= internalBufE;
					end if;	
				
				when SENDEND =>
					-- Fin de l'envoi.
					if (enable = '1' and internalBufE = '0') then
						-- On a reçu de la data, on se prépare à la reémission.
						txd <= '1';
						etat <= INIT;
					elsif (enable = '1') then
						-- On n'a pas reçu de data, on a le droit 
						-- à un repos bien mérité.
						txd <= '1';
						regE <= '1';
						etat <= IDLE;
					end if;
					
					-- Réception pour reémision direct
					if (ld = '1' and internalBufE = '1') then
						bufferT <= data;
						internalBufE := '0';
						bufE <= internalBufE;
					end if;
			end case;
		end if;
	end process;

end behavorial;
