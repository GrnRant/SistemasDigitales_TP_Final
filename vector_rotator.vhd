-------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2015 10:24:29 AM
-- Design Name: 
-- Module Name: vector_rotator
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

library work;
use work.utils.all;

entity vector_rotator is
	generic(
		N: natural := 16
	);
	port(
		--Write side inputs
		clk_pin: in std_logic;		-- Clock input (from pin)
		rst_pin: in std_logic;		-- Active HIGH reset (from pin)
		rxd_pin: in std_logic 		-- Uart input
	);
end;
	

architecture vector_rotator_arq of vector_rotator is
	signal cmd : cordic_ctl_cmds;
	signal ang_a : signed(N + 1 downto 0);
	signal x_i : signed(N + 1 downto 0);
	signal y_i : signed(N + 1 downto 0);
	signal z_i : signed(N + 1 downto 0);
	signal x_o : signed(N + 1 downto 0);
	signal y_o : signed(N + 1 downto 0);
	signal z_o : signed(N + 1 downto 0);
	signal start : std_logic;
begin

	CMD_CTL: entity work.cmd_ctl
		generic map(
			BAUD_RATE => 115200,
			CLOCK_RATE => 50E6,
			N => N
		)
		port map(
			clk_pin => clk_pin,  	-- Clock input (from pin)
			rst_pin => rst_pin,  	-- Active HIGH reset (from pin)
			rxd_pin => rxd_pin,  	-- RS232 RXD pin - directly from pin
			-- Salidas
			cmd_out => cmd,
			ang_out => ang_a
		);
	CORDIC_CTL: entity work.cordic_ctl
		generic map (
			CLOCK_RATE  => 50E6,
			N => N,
			CORDIC_CYCLES => 50E6/50
		)
		port map(
			-- Write side inputs
			clk => clk_pin, -- Clock input (from pin)
			rst => rst_pin, -- Active HIGH reset (from pin)
			cmd_in => cmd, -- Comandos recibidos a ejecutar
			ang_in => ang_a, -- Angulo de entrada para ciertos comandos
			--Outputs del cordic (inputs de cordic_ctl)
			x_cordic_out => x_i, --Valor de entrada al cordic
			y_cordic_out => y_i, --Valor de entrada al cordic
			z_cordic_out => z_i, --Valor de entrada al cordic
			--Inputs al cordic (outputs de cordic_ctl)				
			x_cordic_in => x_o, --Valor de entrada al cordic
			y_cordic_in => y_o, --Valor de entrada al cordic
			z_cordic_in => z_o, --Valor de entrada al cordic
			cordic_start => start
		);
	
end;