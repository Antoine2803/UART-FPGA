library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    read             : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic);
end RxUnit;

architecture RxUnit_arch of RxUnit is
	type tcompteur16 is (idle, waiting, working);				-- type état du compteur 16
	type tcontroleReception is (idlec, workingc, endingc);	-- type état du contrôleur

	signal etat16 : tcompteur16 := idle;							-- état du compteur
	signal tmpRxD : std_logic;
	signal tmpClk : std_logic;
	signal trameEnd : std_logic;										-- permet de signaler la fin de la trame au compteur
	
	signal data_reg : std_logic_vector (7 downto 0);			-- registre pour stocker temporairement les données reçues avant de les envoyer s'il n'y pas d'erreur de parité ou de bit de stop

	signal etatc : tcontroleReception := idlec;					-- état du contrôleur
	signal recep : std_logic;											-- notifier au contrôleur qu'on reçoit de la donnée

begin
	-- Element compteur 16
	process(enable, reset)
		variable cptClk : natural;
	begin
		if (reset = '0') then
			-- Initialisation des signaux
			etat16 <= idle;
			tmpRxD <= '1';
			tmpClk <= '0';
			recep <= '0';

		elsif (rising_edge(enable)) then
			case etat16 is
				when idle =>
					if (rxd = '0') then
						-- Réception bit de start
						cptClk := 8;
						etat16 <= waiting;
						tmpClk <= '0';
					end if;

				when waiting =>
					if (cptClk = 1) then
						-- On a fini d'attendre
						etat16 <= working;
						tmpRxD <= rxd;	-- récupérer la données
						tmpClk <= '1';
						recep <= '1';	-- signaler qu'on commence à recevoir
					else 
						cptClk := cptClk - 1;
					end if;

					if (trameEnd = '1') then 
						-- fin de la reception de la trame
						etat16 <= idle;
						recep <= '0';
					end if;

				when working =>
					-- Repositionner les compteurs
					tmpClk <= '0';
					cptClk := 15;
					etat16 <= waiting;

					if (trameEnd = '1') then 
					-- fin de la reception de la trame 
						etat16 <= idle;
						recep <= '0';
					end if;					
			end case;
		end if;
	end process;

	-- Element controle reception
	process(clk, reset)
		variable cptBit : natural; 
		variable parite_calc : std_logic; -- la parité calculée
		variable parite : std_logic;		 -- bit de parité reçu
		variable stop : std_logic;			 -- bit de stop reçu
	begin
		if (reset = '0') then
			-- Initialisation des signaux
			etatc <= idlec;
			trameEnd <= '0';
			Ferr <= '0';
			OErr <= '0';
			DRdy <= '0';
			data <= (others => '0');
			data_reg <= (others => '0');
			
		elsif (rising_edge(clk)) then
			case etatc is
				when idlec =>					
					OErr <= '0';
					if (recep = '1') then
						-- On commence à recevoir
						cptBit := 10;			-- on repositionne le compteur
						parite := '0';			-- on repositionne la parité à 0
						parite_calc := '0';	-- on repositionne la parité calculée à 0
						etatc <= workingc;
					end if;

				when workingc =>
					-- On commence à recevoir
					if (tmpClk = '1') then
						-- On est prêt à recevoir
						if (3 <= cptBit) then
							-- On reçoit les bits de données utiles
							data_reg(cptBit - 3) <= tmpRxD;
							parite_calc := parite_calc xor tmpRxD; -- mise à jour de la parité
						elsif (cptBit = 2) then 
							-- Réception du bit de parité
							parite := tmpRxD;
						elsif (cptBit = 1) then
							-- Réception du bit de stop
							stop := tmpRxD;
							if ((parite /= parite_calc) or (stop = '0')) then
								-- Erreur de parité ou de bit de stop
								FErr <= '1';
							else
								-- Aucune erreur de parité ou de stop, on est prêt à recevoir à nouveau
								DRdy <= '1';
								data <= data_reg; -- On envoie la donnée
							end if;
							etatc <= endingc;
							trameEnd <= '1'; -- Réception de la trame terminée

						end if;
						cptBit := cptBit - 1;
					end if;

				when endingc =>
					-- La trame à été reçue
					-- Remise à zéro des erreurs
					data_reg <= (others => '0');
					trameEnd <= '0';
					FErr <= '0';
					DRdy <= '0';
					if (read = '0') then
						-- Erreur si l'on a pas réussi à lire la donnée
						OErr <= '1';
					end if;
					etatc <= idlec;
	
			end case;
		end if;
	end process;

end RxUnit_arch;