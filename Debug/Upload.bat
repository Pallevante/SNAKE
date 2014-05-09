@echo off
:A
set /p comPort=Enter the port:%=%
avrdude -C "C:\WinAVR-20100110\bin\avrdude.conf" -patmega328p -Pcom%comPort% -carduino -b115200 -Uflash:w:SNAKE.hex 
pause>nul
goto A