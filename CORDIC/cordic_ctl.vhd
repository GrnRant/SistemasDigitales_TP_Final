library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utils.all;

entity cordic_ctl is
	generic (
		CLOCK_RATE : integer := 50E6;
		N : natural := 16;
		CORDIC_CYCLES : natural := 125E6/50
	);
	port (
		-- Write side inputs
		clk : in std_logic; --Clock input (from pin)
		rst : in std_logic; --Active HIGH reset (from pin)
        cmd_in : in cordic_ctl_cmds; --Comandos recibidos a ejecutar
        ang_in : in signed(N - 1 downto 0); --Angulo de entrada para ciertos comandos
		ang_chg: in std_logic; --Pin de indicación de ángulo nuevo
		--Outputs del cordic (inputs de cordic_ctl)
		x_cordic_out : in signed(N - 1 downto 0); --Valor de entrada al cordic
		y_cordic_out : in signed(N - 1 downto 0); --Valor de entrada al cordic
		z_cordic_out : in signed(N - 1 downto 0); --Valor de entrada al cordic
		cordic_busy : in std_logic;
		--Inputs al cordic (outputs de cordic_ctl)				
		x_cordic_in : out signed(N - 1 downto 0); --Valor de entrada al cordic
		y_cordic_in : out signed(N - 1 downto 0); --Valor de entrada al cordic
		z_cordic_in : out signed(N - 1 downto 0); --Valor de entrada al cordic 
		cordic_start : out std_logic
	);
end;

architecture cordic_ctl_arq of cordic_ctl is
	signal cmd_cycles_count : natural := 0;
	signal actual_ang : signed(N - 1 downto 0) := (others => '0');
	signal ang_chg_trigger : std_logic;
	signal cordic_busy_prev : std_logic;
	constant X_INIT : signed(N - 1 downto 0) := to_signed(0, N); --Posición inicial en Y es 0.75 del máximo valor positivo que puede tener
	constant Y_INIT : signed(N - 1 downto 0) := to_signed(integer(2**(N-2)) , N); --Posición inicial el máximo valor positivo que puede tener (se toma en cuenta que hay que realizar cuentas también)
	constant ANG_ZERO : signed(N - 1 downto 0) := to_signed(0, N); --Ángulo igual a cero
	constant ANG_STEP : signed(N - 1 downto 0) := to_signed(integer((2.0**(N-1)-1.0) / 256.0), N); --Pasos de 0.703125 (escalados)
	constant ANG_STEP_NEG : signed(N - 1 downto 0) := to_signed(integer((2.0**(N-1)-1.0) / 256.0 + 360.0), N); --Pasos de 0.703125 (escalados horario, precordic lo va a volver ángulo negativo)
	constant ANG_CORDIC_SCALE : integer := (2**(N-1)-1)/180; --Escala para los ángulos que se ingresan al cordic

begin
	CORDIC_CTL_CMD_EXE: process(clk)

	begin
		if rising_edge(clk) then
			cordic_busy_prev <= cordic_busy;

			--Reset
			if rst = '1' then
				ang_chg_trigger <= '0';
				x_cordic_in <= X_INIT;
				y_cordic_in <= Y_INIT;
				z_cordic_in <= ANG_ZERO;
				actual_ang <= ANG_ZERO;
				cordic_start <= '0';
				cmd_cycles_count <= CORDIC_CYCLES;
				cordic_busy_prev <= '0';
			end if;

			--Detección de trigger de nuevo ángulo
			if ang_chg_trigger = '0' then
				ang_chg_trigger <= ang_chg;
			end if;

			--Si hay datos nuevos en salida del cordic (flanco descendente de busy) actualizar valores de entrada al cordic
			if cordic_busy = '0' and cordic_busy_prev = '1' then
				x_cordic_in <= x_cordic_out;
				y_cordic_in <= y_cordic_out;
			end if;

			--Chequeo de comandos y actualización de actual_ang y entradas de cordic de acorde con eso:
			C_CMD_IN: case cmd_in is
				--Si comando mover ángulo
				when CMD_A =>
					--Si se detectó nuevo ángulo y no hay ángulo a rotar
					if (ang_chg_trigger = '1') and (actual_ang = ANG_ZERO) then
						actual_ang <= to_signed(to_integer(ang_in)*ANG_CORDIC_SCALE, N);
						z_cordic_in <= ANG_STEP;
						ang_chg_trigger <= '0'; --Reset del trigger
					end if;
				--Si comando giro continuo antihorario
				when CMD_C_A =>
					actual_ang <= ANG_STEP;
					z_cordic_in <= ANG_STEP;
				--Si comando giro continuo horario
				when CMD_C_H =>
					actual_ang <= ANG_STEP;
					z_cordic_in <= ANG_STEP_NEG;
				--Si no hay ningún comando
				when CMD_NONE =>
					actual_ang <= ANG_ZERO;
					z_cordic_in <= ANG_ZERO;
				when others =>

				end case;

				--Si no se llegó a CORDIC_CYCLES seguir esperando
				if cmd_cycles_count < CORDIC_CYCLES then 
					cordic_start <= '0'; --Arranca el cordic si estaba en '1' (por flanco descendente)
					cmd_cycles_count <= cmd_cycles_count + 1;
				--Si se llegó a CORDIC_CYCLES (y busy es '0') arrancar cordic si todavía hay ángulo a rotar (actual_ang)
				else
					if cordic_busy = '0' then
						cmd_cycles_count <= 0;	
						if actual_ang > ANG_ZERO then
							actual_ang <= actual_ang - ANG_STEP;
							cordic_start <= '1'; --Preparar cordic
						else
							actual_ang <= ANG_ZERO;
						end if;
					end if;
				end if;	

		end if;
	end process;
end;