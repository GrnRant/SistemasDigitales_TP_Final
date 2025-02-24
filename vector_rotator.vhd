library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utils.all;

entity vector_rotator is
	generic(
		N_CORDIC: natural := 16;
		N_ADDRESS: natural := 15;
		N_DATA: natural := 16;
		BAUD_RATE: integer := 115200;
		CLOCK_RATE: integer := 125E6;
		CORDIC_ITERATIONS: natural := 15;  --
		CORDIC_CTL_CYCLES: natural := 125E6/50; --Cantidad de ciclos que espera el cordic_ctl para próxima rotación
		COORDS_MAX_TILE_VALUE: natural := 50 --Máximo valor que pueden tomar las coordenadas x e y en tiles
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
	signal rx_data_rdy: std_logic;
	signal rx_data: std_logic_vector(7 downto 0);
	--CMDS_CTL/CORDIC/TILES_GEN
	signal cmd: cordic_ctl_cmds;
	signal cmd_dummy: std_logic_vector(5 downto 0);
	signal ang_a: signed(N_CORDIC - 1 downto 0);
	signal x_i: signed(N_CORDIC - 1 downto 0);
	signal y_i: signed(N_CORDIC - 1 downto 0);
	signal z_i: signed(N_CORDIC - 1 downto 0);
	signal x_o: signed(N_CORDIC - 1 downto 0);
	signal y_o: signed(N_CORDIC - 1 downto 0);
	signal z_o: signed(N_CORDIC - 1 downto 0);
	signal cordic_start: std_logic;
	signal busy: std_logic;
	--TILES_GEN/BRAM
	signal wr_a: std_logic;
	signal addr_a: unsigned(N_ADDRESS - 1 downto 0);
	signal wr_data_a: unsigned(N_DATA - 1 downto 0);

begin
	UART : entity work.uart_top
	generic map(
		CLOCK_RATE => CLOCK_RATE,
		BAUD_RATE => BAUD_RATE
	)
	port map(
		clk_pin => clk_pin,
		rst_pin => rst_pin, 
		rxd_pin => rxd_pin,
		rx_data => rx_data,
		rx_data_rdy => rx_data_rdy
	);
	CMD_CTL: entity work.cmd_ctl
		generic map(
			BAUD_RATE => BAUD_RATE,
			CLOCK_RATE => CLOCK_RATE,
			N => N_CORDIC
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
			CLOCK_RATE  => CLOCK_RATE,
			N => N_CORDIC,
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
			N => N_CORDIC, 
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
	TILE_GEN: entity work.gen_tiles
	generic map(
		N_CORDIC => N_CORDIC,
		N_ADDRESS => N_ADDRESS,
		N_DATA => N_DATA,
		MAX_VAL => COORDS_MAX_TILE_VALUE
	)
	port map(
		rst => rst_pin,
		clk => clk_pin,
		x_in => x_o,
		y_in => y_o,
		cordic_busy => busy,
		wr => wr_a,
		addr => addr_a,
		wr_data => wr_data_a
	);
	
end;