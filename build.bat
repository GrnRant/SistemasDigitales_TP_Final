@echo off

if exist work\ (
    rmdir /s /q work
) 
mkdir work

@REM Syntax
ghdl -s --workdir=work UART_CORDIC/*.vhd
ghdl -s --workdir=work uart_cordic.vhd
@REM Análisis
ghdl -a --workdir=work UART_CORDIC/*.vhd
ghdl -a --workdir=work uart_cordic.vhd
@REM Run
ghdl -r --workdir=work uart_cordic --vcd=work/uart_cordic.vcd