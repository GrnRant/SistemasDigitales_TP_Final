# Sistemas digitales - Trabajo práctico Final

## Arquitectura de rotación de un vector en 2D

Arquitectura de rotación de un vector en 2D, basada en el algoritmo de CORDIC. Recibe comandos por UART y los muestra en pantalla mediante VGA.

**Comandos:**
* ROT A ang
* ROT C A
* ROT C H

### Compilación de archivos y ejecución de simulaciones

Para compilación y simulación rápida ejecutar build.bat (solo para windows). Comentar/descomentar testbenches que se quieran correr o no.

### Arquitecutra general
![Diagrama general](Doc/diagrama_general.png)

### Arquitectura CORDIC enrollada
![CORDIC Rolled](Doc/cordic_rolled.png)

### Resultados simulaciones (sin VGA ni DUAL PORT RAM)

#### Simulación comando ROT A 45

![Simulación comando ROT A 45](Doc/sim_rot_a_ang.png)

#### Simulación comando ROT C A

![Simulación comando ROT C A](Doc/sim_rot_c_a.png)

#### Simulación comando ROT C H

![Simulación comando ROT C H](Doc/sim_rot_c_h.png)

### Resultados pruebas en Vivado (comando ROT A 45)

#### Mediciones en VIO de salidas del CORDIC

![VIO Salidas CORDIC](Doc/vio_rot_a_45.png)

#### Medición Vertical Back Porch de señal de VGA con ILA

![ILA VGA Vertical Back Porch](Doc/ila_rot_a_45_v_back_porch.png)

#### Meidición de tile = (-22;22) en señal VGA con ILA

![ILA VGA Vector](Doc/ila_rot_a_45_vector.png)