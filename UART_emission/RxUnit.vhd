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
	type tcompteur16 is (idle, waiting, working);
	type tcontroleReception is (idle, working, ending);
	
	signal etat16 : tcompteur16 := idle;
	signal tmpRxD : std_logic;
	signal tmpClk : std_logic;
	signal trameEnd : std_logic;
	
	signal tcontrole : tcontroleReception := idle;
	signal recep : std_logic;
begin
	-- Element compteur 16
	process(enable, reset)
		variable cptClk : natural;
	begin
		if (reset = '0') then
			etat16 <= idle;
			tmpRxD <= '1';
			tmpClk <= '0';
			Ferr <= '0';
			OErr <= '0';
			DRdy <= '0';
			data <= (others => '0');
			trameEnd <= '1';
			recep <= '0';
			
		elsif (rising_edge(enable)) then
			case etat16 is
				when idle =>
					if (rxd = '0') then
						cptClk := 8;
						recep <= '1';
						etat16 <= waiting;
					end if;
					
				when waiting =>
					if (cptClk = 0) then 
						etat16 <= working;
						tmpRxD <= rxd;
						tmpClk <= '1';
					else 
						cptClk := cptClk - 1;
					end if;
					
					-- fin de la reception de la trame 
					if (trameEnd = '1') then 
						etat <= idle;
						recep <= '0';
					end if;
					
				when working =>
					tmpClk <= '0';
					cptClk := 16;
					etat16 <= waiting;

					-- fin de la reception de la trame 
					if (trameEnd = '1') then 
						etat <= idle;
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
			tcontrole <= idle;
			trameEnd <= '0';
			
		elsif (rising_edge(clk)) then
			case tcontrole is
				when idle =>
					if (recep = '1') then
						cptBit := 12;
						parite := '0';
						etat <= working;
					end if;
				
				when working =>
					if (tmpClk = '1') then
						if ((3 < cptBit) and (cptBit < 11)) then
							data(cptBit - 3) <= tmpRxD;
							parite_calc := parite_calc xor tmpRxD;
						elsif (cptBit = 2) then 
							parite := tmpRxD;
						elsif (cptBit = 1) then
							stop := tmpRxD;
						end if;
						cptBit := cptBit - 1;
						
						if (cptBit = 0) then 
							if ((parite /= parite_calc) or (stop = '0')) then
								FErr <= '1';
							else
								DRdy <= '1';
							end if;
							etat <= ending;
						end if;
					end if;
					
				when ending =>
					
			end case;
		end if;
	end process;
	
end RxUnit_arch;