@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.2 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Mon Jan 04 12:03:54 +0100 2021
REM SW Build 2708876 on Wed Nov  6 21:40:23 MST 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
echo "xelab -wto e4dd217056204674838b930b8a1c5bc7 --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot uart_tb_behav xil_defaultlib.uart_tb -log elaborate.log"
call xelab  -wto e4dd217056204674838b930b8a1c5bc7 --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot uart_tb_behav xil_defaultlib.uart_tb -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
