-------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2015 10:24:29 AM
-- Design Name: 
-- Module Name: uart_cordic
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--////////////////////////////////////////////////////////////////////////////////

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_cordic is
	generic(
		N: natural := 16
	);
	port(
		--Write side inputs
		clk_pin: in std_logic;		-- Clock input (from pin)
		rst_pin: in std_logic;		-- Active HIGH reset (from pin)
		rxd_pin: in std_logic; 		-- Uart input
		x_cordic_in : out signed(N + 1 downto 0); --Valor de entrada al cordic
		y_cordic_in : out signed(N + 1 downto 0); --Valor de entrada al cordic
		z_cordic_in : out signed(N + 1 downto 0); --Valor de entrada al cordic
		cordic_start : out std_logic;
		cordic_mode : out std_logic
	);
end;
	

architecture uart_cordic_arq of uart_cordic is

	component cordic_ctl is
		generic(
			BAUD_RATE: integer := 115200;   
			CLOCK_RATE: integer := 100E6
		);
		port(
			-- Write side inputs
			clk_pin:	in std_logic;      					-- Clock input (from pin)
			rst_pin: 	in std_logic;      					-- Active HIGH reset (from pin)
			rxd_pin: 	in std_logic;      					-- RS232 RXD pin - directly from pin
			--Inputs al cordic      					
			x_cordic_in: out signed(N + 1 downto 0); --Valor de entrada al cordic
			y_cordic_in: out signed(N + 1 downto 0); --Valor de entrada al cordic
			z_cordic_in: out signed(N + 1 downto 0);  --Valor de entrada al cordic
			cordic_start: out std_logic;
			cordic_mode: out std_logic
		);
	end component;

begin

	U0: cordic_ctl
		generic map(
			BAUD_RATE => 115200,
			CLOCK_RATE => 100E6
		)
		port map(
			clk_pin => clk_pin,  	-- Clock input (from pin)
			rst_pin => rst_pin,  	-- Active HIGH reset (from pin)
			rxd_pin => rxd_pin,  	-- RS232 RXD pin - directly from pin
			--Inputs al cordic      					
			x_cordic_in => x_cordic_in, --Valor de entrada al cordic
			y_cordic_in => y_cordic_in, --Valor de entrada al cordic
			z_cordic_in => z_cordic_in, --Valor de entrada al cordic
			cordic_start => cordic_start, --Para indicar comienzo de cálculos
			cordic_mode => cordic_mode --Para indicar modo rotación o vector
		);
end;