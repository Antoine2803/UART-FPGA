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
	type tcontroleReception is (idlec, workingc, endingc);
	
	signal data_reg : std_logic_vector(7 downto 0);
	
	signal etat16 : tcompteur16 := idle;
	signal etatc : tcontroleReception := idlec;
	signal tmpRxD : std_logic;
	signal tmpClk : std_logic;	

begin
	-- Element compteur 16
	process(clk, reset)
		variable cptClk : natural;
		variable cptBit : natural; 
		variable parite_calc : std_logic; -- la parité calculée
		variable parite : std_logic;		 -- bit de parité reçu
		variable stop : std_logic;			 -- bit de stop reçu
	begin
		if (reset = '0') then
			etat16 <= idle;
			tmpRxD <= '1';
			tmpClk <= '0';
			etatc <= idlec;
			Ferr <= '0';
			OErr <= '0';
			DRdy <= '0';
			data <= (others => '0');
			data_reg <= (others => '0');
			
		elsif  rising_edge(clk) then
			if (enable = '1') then
				case etat16 is
					when idle =>
						if (rxd = '0') then
							cptClk := 8;
							etat16 <= waiting;
							tmpClk <= '0';
						end if;
						
					when waiting =>
						if (cptClk = 0) then 
							etat16 <= working;
							tmpRxD <= rxd;
							tmpClk <= '1';
						else 
							cptClk := cptClk - 1;
						end if;
						
					when working =>
						tmpClk <= '0';
						cptClk := 16;
						etat16 <= waiting;
				
				end case;
			end if;
			
			case etatc is
				when idlec =>
					OErr <= '0';
					Ferr <= '0';
					if (tmpclk = '1') then
						cptBit := 10;
						parite := '0';
						parite_calc := '0';
						etatc <= workingc;
					end if;
				
				when workingc =>
					if (tmpClk = '1') then
						if (3 <= cptBit) then
							data_reg(cptBit - 3) <= tmpRxD;
							parite_calc := parite_calc xor tmpRxD;
						elsif (cptBit = 2) then 
							parite := tmpRxD;
						elsif (cptBit = 1) then
							stop := tmpRxD;
						end if;
						
						if (cptBit = 0) then 
							if ((parite /= parite_calc) or (stop = '0')) then
								FErr <= '1';
							else
								DRdy <= '1';
								data <= data_reg;
							end if;
							etatc <= endingc;
						end if;
						cptBit := cptBit - 1;
					end if;
					
				when endingc =>
					FErr <= '0';
					DRdy <= '0';
					if (read = '0') then
						OErr <= '1';
					end if;
					etatc <= idlec;
					etat16 <= idle;
					
			end case;
		end if;
	end process;
	
end RxUnit_arch;
