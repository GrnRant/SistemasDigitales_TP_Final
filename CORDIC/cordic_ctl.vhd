library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utils.all;

entity cordic_ctl is
	generic (
		CLOCK_RATE : integer := 50E6;
		N : natural := 16;
		CORDIC_CYCLES : natural := 50E6/50
	);
	port (
		-- Write side inputs
		clk : in std_logic; -- Clock input (from pin)
		rst : in std_logic; -- Active HIGH reset (from pin)
        cmd_in : in cordic_ctl_cmds; -- Comandos recibidos a ejecutar
        ang_in : in signed(N - 1 downto 0); -- Angulo de entrada para ciertos comandos
		--Outputs del cordic (inputs de cordic_ctl)
		x_cordic_out : in signed(N - 1 downto 0); --Valor de entrada al cordic
		y_cordic_out : in signed(N - 1 downto 0); --Valor de entrada al cordic
		z_cordic_out : in signed(N - 1 downto 0); --Valor de entrada al cordic
		--Inputs al cordic (outputs de cordic_ctl)				
		x_cordic_in : out signed(N - 1 downto 0); --Valor de entrada al cordic
		y_cordic_in : out signed(N - 1 downto 0); --Valor de entrada al cordic
		z_cordic_in : out signed(N - 1 downto 0); --Valor de entrada al cordic 
		cordic_start : out std_logic
	);
end;

architecture cordic_ctl_arq of cordic_ctl is

	signal x_cordic_in_aux : signed(N - 1 downto 0) := (others => '0');
	signal y_cordic_in_aux: signed(N - 1 downto 0) := (others => '0');
	signal z_cordic_in_aux : signed(N - 1 downto 0) := (others => '0');
	signal cmd_cycles_count : natural := 0;
	signal ang_in_pre : signed(N - 1 downto 0);
	signal actual_ang : signed(N - 1 downto 0) := (others => '0');
	constant X_INIT : signed(N - 1 downto 0) := to_signed(0, N); --Posición inicial en Y es 0.75 del máximo valor positivo que puede tener
	constant Y_INIT : signed(N - 1 downto 0) := to_signed(integer((2**(N-1) - 1) * 3 / 4), N); --Posición inicial en Y es 0.75 del máximo valor positivo que puede tener
	constant ANG_ZERO : signed(N - 1 downto 0) := to_signed(0, N); --Ángulo igual a cero
	constant ANG_STEP : signed(N - 1 downto 0) := to_signed(integer((2.0**(N-1)-1.0) / 256.0), N); --Pasos de 0.703125 (escalados)
	constant ERROR : signed(N - 1 downto 0) := to_signed(1, N); --Error

begin
	CORDIC_CTL_CMD_EXE: process(clk)

	begin
		if rising_edge(clk) then
			if rst = '1' then
				x_cordic_in <= X_INIT;
				y_cordic_in <= Y_INIT;
				z_cordic_in <= ANG_ZERO;
				cordic_start <= '1'; -- Flanco descendente para arrancar cordic
				cmd_cycles_count <= 0;
			end if;
			
			--Si no se llegó a CORDIC_CYCLES seguir esperando
			if cmd_cycles_count < CORDIC_CYCLES then
				cordic_start <= '0'; --Arranca el cordic si no lo estaba (por flanco descendente)
				cmd_cycles_count <= cmd_cycles_count + 1;
			--Si se llegó a CORDIC_CYCLES procesar siguiente entrada al cordic según comando
			else
				cordic_start <= '1'; --Preparar cordic
				cmd_cycles_count <= 0;
				C_CMD_IN: case cmd_in is
					--Si comando mover ángulo
					when CMD_A =>
						--Si cambió ang_in con respecto a ciclo anterior hay nuevo ángulo
						if ang_in_pre /= ang_in then
							z_cordic_in <= ANG_STEP;
							actual_ang <= ang_in;
						--Si todavía no se llegó a posición avanzar un paso más (cuidado con margen de error de z_cordic_out)
						elsif actual_ang > ANG_ZERO then
							x_cordic_in <= x_cordic_out;
							y_cordic_in <= y_cordic_out;
							z_cordic_in <= ANG_STEP;
							actual_ang <= ang_in - ANG_STEP;
						--Si ya se llegó a posición no hacer nada
						else
							x_cordic_in <= x_cordic_out;
							y_cordic_in <= y_cordic_out;	
							z_cordic_in <= ANG_ZERO;
						end if;
					--Si comando giro continuo antihorario
					when CMD_C_A =>
						x_cordic_in <= x_cordic_out;
						y_cordic_in <= y_cordic_out;
						z_cordic_in <= ANG_STEP;
					--Si comando giro continuo horario
					when CMD_C_H =>
						x_cordic_in <= x_cordic_out;
						y_cordic_in <= y_cordic_out;
						z_cordic_in <= ANG_STEP;
					--Si no hay ningún comando
					when CMD_NONE =>
						x_cordic_in <= x_cordic_out;
						y_cordic_in <= y_cordic_out;	
						z_cordic_in <= ANG_ZERO;
					end case;			
			end if;
			ang_in_pre <= ang_in;
		end if;
	end process;
end;