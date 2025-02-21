library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utils.all;

entity vector_rotator is
	generic(
		N: natural := 16;
		BAUD_RATE: integer := 115200;
		CLOCK_RATE: integer := 50E6;
		CORDIC_ITERATIONS: natural := 15 
	);
	port(
		--Write side inputs
		clk_pin: in std_logic;		-- Clock input (from pin)
		rst_pin: in std_logic;		-- Active HIGH reset (from pin)
		rxd_pin: in std_logic 		-- Uart input
	);
end;
	

architecture vector_rotator_arq of vector_rotator is
	--UART/CMD_CTL
	signal rst_clk_rx : std_logic;
	signal rx_data_rdy : std_logic;
	signal rx_data : std_logic_vector(7 downto 0);
	--CMDS_CTL/CORDIC
	signal cmd : cordic_ctl_cmds;
	signal ang_a : signed(N - 1 downto 0);
	signal x_i : signed(N - 1 downto 0);
	signal y_i : signed(N - 1 downto 0);
	signal z_i : signed(N - 1 downto 0);
	signal x_o : signed(N - 1 downto 0);
	signal y_o : signed(N - 1 downto 0);
	signal z_o : signed(N - 1 downto 0);
	signal cordic_start : std_logic;
	signal busy : std_logic;

begin
	META_HARDEN_RST: entity work.meta_harden
	port map(
		clk_dst => clk_pin,
		rst_dst => '0', -- No reset on the hardener for reset!
		signal_src => rst_pin,
		signal_dst => rst_clk_rx
	);
	UART_RX : entity work.uart_rx
	generic map(
		CLOCK_RATE => CLOCK_RATE,
		BAUD_RATE => BAUD_RATE
	)
	port map(
		clk_rx => clk_pin,
		rst_clk_rx => rst_clk_rx,

		rxd_i => rxd_pin,
		rxd_clk_rx => open,

		rx_data_rdy => rx_data_rdy,
		rx_data => rx_data,
		frm_err => open
	);
	CMD_CTL: entity work.cmd_ctl
		generic map(
			BAUD_RATE => 115200,
			CLOCK_RATE => 50E6,
			N => N
		)
		port map(
			clk_pin => clk_pin,  	-- Clock input (from pin)
			rst_pin => rst_pin,  	-- Active HIGH reset (from pin)
			rx_data => rx_data, -- Data output of uart_rx
			rx_data_rdy => rx_data_rdy,
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
			x_cordic_out => x_o, --Valor de salida del cordic
			y_cordic_out => y_o, --Valor de salida del cordic
			z_cordic_out => z_o, --Valor de salida del cordic
			--Inputs al cordic (outputs de cordic_ctl)				
			x_cordic_in => x_i, --Valor de entrada al cordic
			y_cordic_in => y_i, --Valor de entrada al cordic
			z_cordic_in => z_i, --Valor de entrada al cordic
			cordic_start => cordic_start
		);
	CORDIC: entity work.cordic
		generic map(
			N => N, 
			ITERATIONS => CORDIC_ITERATIONS
			)
		port map(
			x0 => x_i,
			y0 => y_i,
			z0 => z_i,
			xr => x_o,
			yr => y_o,
			zr => y_o,
			start => cordic_start, 
			clk => clk_pin,
			mode => '1',
			busy => busy
		);
	
end;