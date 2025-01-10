--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:57:03 12/10/2024
-- Design Name:   
-- Module Name:   /home/ary6761/Documents/S7/Archi/xilinx/UART_recep/testRXUnit.vhd
-- Project Name:  UART_recep
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RxUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testRXUnit IS
END testRXUnit;
 
ARCHITECTURE behavior OF testRXUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RxUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         read : IN  std_logic;
         rxd : IN  std_logic;
         data : OUT  std_logic_vector(7 downto 0);
         Ferr : OUT  std_logic;
         OErr : OUT  std_logic;
         DRdy : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable : std_logic := '0';
   signal read : std_logic := '0';
   signal rxd : std_logic := '1';

 	--Outputs
   signal data : std_logic_vector(7 downto 0);
   signal Ferr : std_logic;
   signal OErr : std_logic;
   signal DRdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => enable,
          read => read,
          rxd => rxd,
          data => data,
          Ferr => Ferr,
          OErr => OErr,
          DRdy => DRdy
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	enable <= clk;
   -- Stimulus process
   stim_proc: process
   begin		
      reset <= '0';
      wait for 100 ns;	
			reset <= '1';
			
			wait for 20 ns;
			
			rxd <= '0';
      wait for clk_period*18;
			rxd <= '1';
      wait for clk_period*18;
			rxd <= '1';
      wait for clk_period*18;
			rxd <= '1';
      wait for clk_period*18;
			rxd <= '1';
      wait for clk_period*18;
			rxd <= '1';
      wait for clk_period*18;
			rxd <= '1';
      wait for clk_period*18;
			rxd <= '1';
      wait for clk_period*18;
			rxd <= '1';
      wait for clk_period*18;
			rxd <= '0';
      wait for clk_period*18;
			rxd <= '1';
			wait for 264 ns;
			read <= '1';
			wait for clk_period*2;
			read <= '0';


      wait;
   end process;

END;
