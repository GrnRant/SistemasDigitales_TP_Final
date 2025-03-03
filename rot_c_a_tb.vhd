library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

library work;
use work.utils.all;

entity rot_c_a_tb is 
end entity rot_c_a_tb;

architecture rot_c_a_tb_arq of rot_c_a_tb is
    constant CLOCK_RATE: natural := 125E6;
    constant CLOCK_SWITCH_TIME: time := 4 ns; --Medio período del clock en ns
    constant BAUD_RATE: natural := 115200;
    constant N_CORDIC: natural := 16;
    constant N_ADDRESS: natural := 11;
    constant N_DATA: natural := 16;
    constant CORDIC_ITERATIONS: natural := 15;
    constant CORDIC_CTL_CYCLES: natural := 500;

    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '1';
    signal rxd_tb : std_logic := '0';

begin

    clk_tb <= not clk_tb after CLOCK_SWITCH_TIME; 
    rst_tb <= '0' after 14 ns;

    TEST: process is 
    begin
        report "Inicio test ROT C A"
        severity note;
        
        wait until rst_tb = '0';
        wait for 10 ns;
      
        rxd_tb <= '1';  -- IDLE
        wait for 8681 ns; -- Tiempo de un bit: 1/BAUD_RATE. En este caso BAUD_RATE = 115200 => 8680,555 => 8681 redondeando
        
        rxd_tb <= '0'; -- START
        wait for 8681 ns;
            
        -- Envio letra R
        rxd_tb <= '0';  --bit(0) de la R = "01010010", se envia de derecha a izquierda. Empezando por el LSB
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(1) de la R
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(2) de la R
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(3) de la R
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(4) de la R
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(5) de la R
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(6) de la R
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(7) de la R
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- STOP
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- IDLE
        wait for 8681 ns;
        
        -- Envio letra O
    
        rxd_tb <= '0';   -- START
        wait for 8681 ns;
    
        rxd_tb <= '1';  --bit(0) de la O = "01001111"
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(1) de la O
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(2) de la O
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(3) de la O
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(4) de la O
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(5) de la O
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(6) de la O
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(7) de la O
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- STOP
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- IDLE
        wait for 8681 ns;
        
        -- Envio letra T
    
        rxd_tb <= '0';   -- START
        wait for 8681 ns;
    
        rxd_tb <= '0';  --bit(0) de la T = "01010100"
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(1) de la T
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(2) de la T
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(3) de la T
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(4) de la T
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(5) de la T
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(6) de la T
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(7) de la T
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- STOP
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- IDLE
        wait for 8681 ns;
        
        -- Envio ESACIO
    
        rxd_tb <= '0';   -- START
        wait for 8681 ns;
    
        rxd_tb <= '0';  --bit(0) de ESPACIO = "00100000"
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(1) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(2) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(3) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(4) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(5) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(6) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(7) de ESPACIO
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- STOP
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- IDLE
        wait for 8681 ns;
                
        -- Envio letra C (Rotacion Continua)
    
        rxd_tb <= '0';   -- START
        wait for 8681 ns;
    
        rxd_tb <= '1';  --bit(0) de la C = "01000011"
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(1) de la C
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(2) de la C
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(3) de la C
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(4) de la C
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(5) de la C
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(6) de la C
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(7) de la C
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- STOP
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- IDLE
        wait for 8681 ns;
        
        -- Envio ESACIO
    
        rxd_tb <= '0';   -- START
        wait for 8681 ns;
    
        rxd_tb <= '0';  --bit(0) de ESPACIO = "00100000"
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(1) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(2) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(3) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(4) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(5) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(6) de ESPACIO
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(7) de ESPACIO
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- STOP
        wait for 8681 ns;
    
        rxd_tb <= '1';   -- IDLE
        wait for 8681 ns;
        
        -- Envio letra A (Sentido de rotacion continua Anti-Horario)
            
        rxd_tb <= '0';   -- START
        wait for 8681 ns;

        rxd_tb <= '1';  --bit(0) de la A = "01000001"
        wait for 8681 ns;

        rxd_tb <= '0';  --bit(1) de la A
        wait for 8681 ns;

        rxd_tb <= '0';  --bit(2) de la A
        wait for 8681 ns;

        rxd_tb <= '0';  --bit(3) de la A
        wait for 8681 ns;

        rxd_tb <= '0';  --bit(4) de la A
        wait for 8681 ns;

        rxd_tb <= '0';  --bit(5) de la A
        wait for 8681 ns;

        rxd_tb <= '1';  --bit(6) de la A
        wait for 8681 ns;

        rxd_tb <= '0';  --bit(7) de la A
        wait for 8681 ns;

        rxd_tb <= '1';   -- STOP
        wait for 8681 ns;

        rxd_tb <= '1';   -- IDLE
        wait for 8681 ns;
    
        -- Envio ENTER (Carriage Return)
    
        rxd_tb <= '0';   -- START
        wait for 8681 ns;
    
        rxd_tb <= '0';  --bit(0) de ENTER = "00001010"
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(1) de ENTER
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(2) de ENTER
        wait for 8681 ns;
        
        rxd_tb <= '1';  --bit(3) de ENTER
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(4) de ENTER
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(5) de ENTER
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(6) de ENTER
        wait for 8681 ns;
        
        rxd_tb <= '0';  --bit(7) de ENTER
        wait for 8681 ns;
        
       rxd_tb <= '1'; -- STOP
       wait for 8681 ns;
       
       rxd_tb <= '1'; -- IDLE
       wait for 2 ms;
       
       -- Se aborta la simulacion
        assert false report
            "Fin de la simulacion" severity failure;
       
    end process TEST;

    --Cambiar arquitectura en función de la que se quiera probar
    DUT_VECTOR_ROTATOR: entity work.vector_rotator
	generic map(
		N_CORDIC => N_CORDIC,
		N_ADDRESS => N_ADDRESS,
		N_DATA => N_DATA,
		BAUD_RATE => BAUD_RATE,
		CLOCK_RATE => CLOCK_RATE,
		CORDIC_ITERATIONS => CORDIC_ITERATIONS, 
		CORDIC_CTL_CYCLES => CORDIC_CTL_CYCLES
    )
	port map(
		clk_pin => clk_tb,
		rst_pin => rst_tb,
		rxd_pin => rxd_tb
	);

end architecture rot_c_a_tb_arq;