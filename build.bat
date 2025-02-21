@echo off

if exist build\ (
    rmdir /s /q build
) 
mkdir build

@REM uart_cmd
ghdl -a --workdir=build uart_cmd/meta_harden.vhd
ghdl -a --workdir=build uart_cmd/uart_baud_gen.vhd
ghdl -a --workdir=build uart_cmd/uart_rx_ctl.vhd
ghdl -a --workdir=build uart_cmd/uart_rx.vhd
ghdl -a --workdir=build utilities/utilities.vhd
ghdl -a --workdir=build uart_cmd/cmd_ctl.vhd
ghdl -a --workdir=build cordic/cordic_ctl.vhd
ghdl -a --workdir=build utilities/ffd.vhd
ghdl -a --workdir=build utilities/counter.vhd
ghdl -a --workdir=build cordic/cordic_stage.vhd
ghdl -a --workdir=build cordic/precordic.vhd
ghdl -a --workdir=build cordic/cordic.vhd

@REM GENERAL
ghdl -a --workdir=build vector_rotator.vhd

@REM Run
ghdl -r --workdir=build vector_rotator --vcd=build/vector_rotator.vcd