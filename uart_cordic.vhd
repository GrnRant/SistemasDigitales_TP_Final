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
		btn_pin: in std_logic;		-- Button to swap high and low bits
		rxd_pin: in std_logic; 		-- Uart input
		led_pins: out std_logic_vector(7 downto 0) -- 4 LED outputs
	);
end;
	

architecture uart_cordic_arq of uart_cordic is

	--Inputs al cordic      					
	signal x_cordic_in: signed(N + 1 downto 0); --Valor de entrada al cordic
	signal y_cordic_in: signed(N + 1 downto 0); --Valor de entrada al cordic
	signal z_cordic_in: signed(N + 1 downto 0);  --Valor de entrada al cordic

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
			z_cordic_in: out signed(N + 1 downto 0)  --Valor de entrada al cordic
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
			z_cordic_in => z_cordic_in --Valor de entrada al cordic
		);
end;