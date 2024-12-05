library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
	port (
		clk, reset : in  std_logic;
		enableTX   : out std_logic;
		enableRX   : out std_logic
	);
end clkUnit;

architecture behavorial of clkUnit is
	
begin
	process(reset, clk)
		variable cptTX : natural;	-- compteur pour générer la clk plus lente (cycle de 16 tics)
	begin
		if (reset = '0') then
			-- Réinitialiser les signaux et variables.
			cptTX := 0;
			enableTX <= '0';
			enableRX <= '0';
		else
			if (rising_edge(clk)) then
				if (cptTX = 15) then
					-- Fin du cycle de 16 tics, on réinitialise le compteur
					-- et on active enableTX.
					cptTX := 0;
					enableTX <= '1';
				else
					-- enableTX désactivé et incrémentation du compteur du cycle
					enableTX <= '0';
					cptTX := cptTX + 1;
				end if;
			end if;
			
			-- enableRX = clk
			enableRX <= clk;
		end if;
	end process;
end behavorial;
