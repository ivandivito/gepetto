EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:circuito-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "placa interprete fresadora CNC"
Date "2015-10-23"
Rev "1"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L ATMEGA328-P IC1
U 1 1 562A82A8
P 4700 2800
F 0 "IC1" H 3950 4050 40  0000 L BNN
F 1 "ATMEGA328-P" H 5100 1400 40  0000 L BNN
F 2 "Housings_DIP:DIP-28_W7.62mm_LongPads" H 4700 2800 30  0000 C CIN
F 3 "" H 4700 2800 60  0000 C CNN
	1    4700 2800
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X04 P5
U 1 1 562A85F8
P 8050 2900
F 0 "P5" H 8050 3150 50  0000 C CNN
F 1 "CONN_EJE_Z" V 8150 2900 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x04" H 8050 2900 60  0001 C CNN
F 3 "" H 8050 2900 60  0000 C CNN
	1    8050 2900
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X04 P4
U 1 1 562A86EB
P 8050 2200
F 0 "P4" H 8050 2450 50  0000 C CNN
F 1 "CONN_EJE_Y" V 8150 2200 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x04" H 8050 2200 60  0001 C CNN
F 3 "" H 8050 2200 60  0000 C CNN
	1    8050 2200
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X04 P3
U 1 1 562A87F6
P 8050 1500
F 0 "P3" H 8050 1750 50  0000 C CNN
F 1 "CONN_EJE_X" V 8150 1500 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x04" H 8050 1500 60  0001 C CNN
F 3 "" H 8050 1500 60  0000 C CNN
	1    8050 1500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR01
U 1 1 562A8ADE
P 7800 2400
F 0 "#PWR01" H 7800 2150 50  0001 C CNN
F 1 "GND" H 7800 2250 50  0000 C CNN
F 2 "" H 7800 2400 60  0000 C CNN
F 3 "" H 7800 2400 60  0000 C CNN
	1    7800 2400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 562A8AFA
P 7800 1700
F 0 "#PWR02" H 7800 1450 50  0001 C CNN
F 1 "GND" H 7800 1550 50  0000 C CNN
F 2 "" H 7800 1700 60  0000 C CNN
F 3 "" H 7800 1700 60  0000 C CNN
	1    7800 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 1700 7800 1650
Wire Wire Line
	7800 1650 7850 1650
Wire Wire Line
	7800 2400 7800 2350
Wire Wire Line
	7800 2350 7850 2350
Wire Wire Line
	7800 3100 7800 3050
Wire Wire Line
	7800 3050 7850 3050
Text Label 7850 2950 2    60   ~ 0
step_Z
Text Label 7850 2850 2    60   ~ 0
dir_Z
Text Label 7850 1350 2    60   ~ 0
enable
Text Label 7850 2150 2    60   ~ 0
dir_Y
Text Label 7850 1450 2    60   ~ 0
dir_X
Text Label 7850 2250 2    60   ~ 0
step_Y
Text Label 7850 1550 2    60   ~ 0
step_X
Text Label 7850 2050 2    60   ~ 0
enable
Text Label 7850 2750 2    60   ~ 0
enable
Text Label 5700 1700 0    60   ~ 0
enable
Text Label 5700 3800 0    60   ~ 0
dir_X
Text Label 5700 3500 0    60   ~ 0
step_X
Text Label 5700 3900 0    60   ~ 0
dir_Y
Text Label 5700 3600 0    60   ~ 0
step_Y
Text Label 5700 4000 0    60   ~ 0
dir_Z
Text Label 5700 3700 0    60   ~ 0
step_Z
Text Label 5700 1800 0    60   ~ 0
lim_X
Text Label 5700 1900 0    60   ~ 0
lim_Y
Text Label 2250 3500 0    60   ~ 0
lim_Z
Text Label 2250 3400 0    60   ~ 0
hus_vel
Text Label 5700 2200 0    60   ~ 0
hus_dir
Text Label 5700 2550 0    60   ~ 0
button_stop
Text Label 5700 3300 0    60   ~ 0
Rx_int
Text Label 5700 3400 0    60   ~ 0
Tx_int
$Comp
L CONN_01X03 P6
U 1 1 562A97EA
P 8050 3550
F 0 "P6" H 8050 3750 50  0000 C CNN
F 1 "CONN_HUS" V 8150 3550 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 8050 3550 60  0001 C CNN
F 3 "" H 8050 3550 60  0000 C CNN
	1    8050 3550
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X03 P7
U 1 1 562A9970
P 8050 4150
F 0 "P7" H 8050 4350 50  0000 C CNN
F 1 "CONN_UART" V 8150 4150 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 8050 4150 60  0001 C CNN
F 3 "" H 8050 4150 60  0000 C CNN
	1    8050 4150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR03
U 1 1 562A9A63
P 7800 3700
F 0 "#PWR03" H 7800 3450 50  0001 C CNN
F 1 "GND" H 7800 3550 50  0000 C CNN
F 2 "" H 7800 3700 60  0000 C CNN
F 3 "" H 7800 3700 60  0000 C CNN
	1    7800 3700
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR04
U 1 1 562A9A80
P 7800 4300
F 0 "#PWR04" H 7800 4050 50  0001 C CNN
F 1 "GND" H 7800 4150 50  0000 C CNN
F 2 "" H 7800 4300 60  0000 C CNN
F 3 "" H 7800 4300 60  0000 C CNN
	1    7800 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 4300 7800 4250
Wire Wire Line
	7800 4250 7850 4250
Wire Wire Line
	7800 3700 7800 3650
Wire Wire Line
	7800 3650 7850 3650
Text Label 7850 3550 2    60   ~ 0
hus_dir
Text Label 7850 3450 2    60   ~ 0
hus_vel
Text Label 7850 4050 2    60   ~ 0
Rx_int
Text Label 7850 4150 2    60   ~ 0
Tx_int
$Comp
L GND #PWR05
U 1 1 562AA37D
P 3700 4050
F 0 "#PWR05" H 3700 3800 50  0001 C CNN
F 1 "GND" H 3700 3900 50  0000 C CNN
F 2 "" H 3700 4050 60  0000 C CNN
F 3 "" H 3700 4050 60  0000 C CNN
	1    3700 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 3900 3700 4050
Wire Wire Line
	3700 3900 3800 3900
Wire Wire Line
	3700 4000 3800 4000
Connection ~ 3700 4000
Wire Wire Line
	3750 2000 3800 2000
Wire Wire Line
	3750 1700 3800 1700
Wire Wire Line
	3750 1850 3650 1850
Connection ~ 3750 1850
$Comp
L Crystal Y1
U 1 1 562AA90E
P 6550 2500
F 0 "Y1" H 6550 2650 50  0000 C CNN
F 1 "16Mhz" H 6550 2350 50  0000 C CNN
F 2 "Crystals:Crystal_HC48-U_Vertical" H 6550 2500 60  0001 C CNN
F 3 "" H 6550 2500 60  0000 C CNN
	1    6550 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 2400 6400 2400
Wire Wire Line
	6400 2400 6400 2700
Wire Wire Line
	5700 2300 6400 2300
Wire Wire Line
	6400 2300 6400 2250
Wire Wire Line
	6400 2250 6700 2250
Wire Wire Line
	6700 2250 6700 2700
$Comp
L C C2
U 1 1 562AAB38
P 6400 2850
F 0 "C2" H 6425 2950 50  0000 L CNN
F 1 "22 pF" H 6425 2750 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 6438 2700 30  0001 C CNN
F 3 "" H 6400 2850 60  0000 C CNN
	1    6400 2850
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR06
U 1 1 562AABCC
P 6550 3100
F 0 "#PWR06" H 6550 2850 50  0001 C CNN
F 1 "GND" H 6550 2950 50  0000 C CNN
F 2 "" H 6550 3100 60  0000 C CNN
F 3 "" H 6550 3100 60  0000 C CNN
	1    6550 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	6400 3000 6400 3050
Wire Wire Line
	6400 3050 6700 3050
Wire Wire Line
	6700 3050 6700 3000
Wire Wire Line
	6550 3100 6550 3050
Connection ~ 6550 3050
Connection ~ 6700 2500
Connection ~ 6400 2500
$Comp
L C C3
U 1 1 562AAE12
P 6700 2850
F 0 "C3" H 6725 2950 50  0000 L CNN
F 1 "22 pF" H 6725 2750 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 6738 2700 30  0001 C CNN
F 3 "" H 6700 2850 60  0000 C CNN
	1    6700 2850
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR07
U 1 1 562ABE39
P 9350 1900
F 0 "#PWR07" H 9350 1650 50  0001 C CNN
F 1 "GND" H 9350 1750 50  0000 C CNN
F 2 "" H 9350 1900 60  0000 C CNN
F 3 "" H 9350 1900 60  0000 C CNN
	1    9350 1900
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P9
U 1 1 562ABEF1
P 9650 1500
F 0 "P9" H 9650 1650 50  0000 C CNN
F 1 "CONN_LIM_X" V 9750 1500 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 9650 1500 60  0001 C CNN
F 3 "" H 9650 1500 60  0000 C CNN
	1    9650 1500
	1    0    0    -1  
$EndComp
Wire Wire Line
	9250 1450 9450 1450
$Comp
L R R2
U 1 1 562AC0EB
P 9350 1750
F 0 "R2" V 9430 1750 50  0000 C CNN
F 1 "15 k" V 9350 1750 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 9280 1750 30  0001 C CNN
F 3 "" H 9350 1750 30  0000 C CNN
	1    9350 1750
	1    0    0    -1  
$EndComp
Wire Wire Line
	9350 1850 9350 1900
Text Label 9250 1550 2    60   ~ 0
lim_X
Connection ~ 9350 1550
Wire Wire Line
	9350 1600 9350 1550
Wire Wire Line
	9250 1550 9450 1550
$Comp
L GND #PWR08
U 1 1 562AE343
P 9350 2750
F 0 "#PWR08" H 9350 2500 50  0001 C CNN
F 1 "GND" H 9350 2600 50  0000 C CNN
F 2 "" H 9350 2750 60  0000 C CNN
F 3 "" H 9350 2750 60  0000 C CNN
	1    9350 2750
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P10
U 1 1 562AE349
P 9650 2350
F 0 "P10" H 9650 2500 50  0000 C CNN
F 1 "CONN_LIM_Y" V 9750 2350 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 9650 2350 60  0001 C CNN
F 3 "" H 9650 2350 60  0000 C CNN
	1    9650 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	9250 2300 9450 2300
$Comp
L R R3
U 1 1 562AE352
P 9350 2600
F 0 "R3" V 9430 2600 50  0000 C CNN
F 1 "15 k" V 9350 2600 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 9280 2600 30  0001 C CNN
F 3 "" H 9350 2600 30  0000 C CNN
	1    9350 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	9350 2700 9350 2750
Text Label 9250 2400 2    60   ~ 0
lim_Y
Connection ~ 9350 2400
Wire Wire Line
	9350 2450 9350 2400
Wire Wire Line
	9250 2400 9450 2400
$Comp
L GND #PWR09
U 1 1 562AE45B
P 9300 3600
F 0 "#PWR09" H 9300 3350 50  0001 C CNN
F 1 "GND" H 9300 3450 50  0000 C CNN
F 2 "" H 9300 3600 60  0000 C CNN
F 3 "" H 9300 3600 60  0000 C CNN
	1    9300 3600
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P8
U 1 1 562AE461
P 9600 3200
F 0 "P8" H 9600 3350 50  0000 C CNN
F 1 "CONN_LIM_Z" V 9700 3200 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 9600 3200 60  0001 C CNN
F 3 "" H 9600 3200 60  0000 C CNN
	1    9600 3200
	1    0    0    -1  
$EndComp
Wire Wire Line
	9200 3150 9400 3150
$Comp
L R R1
U 1 1 562AE46A
P 9300 3450
F 0 "R1" V 9380 3450 50  0000 C CNN
F 1 "15 k" V 9300 3450 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 9230 3450 30  0001 C CNN
F 3 "" H 9300 3450 30  0000 C CNN
	1    9300 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	9300 3550 9300 3600
Text Label 9200 3250 2    60   ~ 0
lim_Z
Connection ~ 9300 3250
Wire Wire Line
	9300 3300 9300 3250
Wire Wire Line
	9200 3250 9400 3250
Text Label 9250 4200 2    60   ~ 0
button_stop
$Comp
L GND #PWR010
U 1 1 562B2AB2
P 9350 4550
F 0 "#PWR010" H 9350 4300 50  0001 C CNN
F 1 "GND" H 9350 4400 50  0000 C CNN
F 2 "" H 9350 4550 60  0000 C CNN
F 3 "" H 9350 4550 60  0000 C CNN
	1    9350 4550
	1    0    0    -1  
$EndComp
$Comp
L R R4
U 1 1 562B2AC0
P 9350 4400
F 0 "R4" V 9430 4400 50  0000 C CNN
F 1 "15 k" V 9350 4400 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 9280 4400 30  0001 C CNN
F 3 "" H 9350 4400 30  0000 C CNN
	1    9350 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	9350 4500 9350 4550
Connection ~ 9350 4200
Wire Wire Line
	9350 4250 9350 4200
$Comp
L GND #PWR011
U 1 1 562B5782
P 2350 2200
F 0 "#PWR011" H 2350 1950 50  0001 C CNN
F 1 "GND" H 2350 2050 50  0000 C CNN
F 2 "" H 2350 2200 60  0000 C CNN
F 3 "" H 2350 2200 60  0000 C CNN
	1    2350 2200
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P1
U 1 1 562B588F
P 2100 2100
F 0 "P1" H 2100 2250 50  0000 C CNN
F 1 "CONN_5V" V 2200 2100 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 2100 2100 60  0001 C CNN
F 3 "" H 2100 2100 60  0000 C CNN
	1    2100 2100
	-1   0    0    1   
$EndComp
Wire Wire Line
	2350 2150 2350 2200
Wire Wire Line
	2350 2050 2350 2000
Wire Wire Line
	2300 2050 2350 2050
Wire Wire Line
	2350 2150 2300 2150
$Comp
L CONN_02X03 P2
U 1 1 562B8440
P 2150 2750
F 0 "P2" H 2150 2950 50  0000 C CNN
F 1 "CONN_02X03" H 2150 2550 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03" H 2150 1550 60  0001 C CNN
F 3 "" H 2150 1550 60  0000 C CNN
	1    2150 2750
	1    0    0    -1  
$EndComp
Text Label 2400 2750 0    60   ~ 0
MOSI
Text Label 1900 2650 2    60   ~ 0
MISO
$Comp
L GND #PWR012
U 1 1 562B940D
P 2450 2900
F 0 "#PWR012" H 2450 2650 50  0001 C CNN
F 1 "GND" H 2450 2750 50  0000 C CNN
F 2 "" H 2450 2900 60  0000 C CNN
F 3 "" H 2450 2900 60  0000 C CNN
	1    2450 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	2400 2850 2450 2850
Wire Wire Line
	2450 2850 2450 2900
Text Label 1900 2750 2    60   ~ 0
SCK
Text Label 5700 3150 0    60   ~ 0
RESET
Text Label 2050 3400 2    60   ~ 0
MOSI
Text Label 2050 3500 2    60   ~ 0
MISO
Text Label 2050 3600 2    60   ~ 0
SCK
Text Label 5700 2000 0    60   ~ 0
hus_vel
Text Label 5700 2100 0    60   ~ 0
lim_Z
Text Label 2250 3600 0    60   ~ 0
hus_dir
Wire Wire Line
	2050 3600 2250 3600
Wire Wire Line
	2050 3500 2250 3500
Wire Wire Line
	2050 3400 2250 3400
$Comp
L VCC #PWR013
U 1 1 562D4658
P 3650 1850
F 0 "#PWR013" H 3650 1700 50  0001 C CNN
F 1 "VCC" H 3650 2000 50  0000 C CNN
F 2 "" H 3650 1850 60  0000 C CNN
F 3 "" H 3650 1850 60  0000 C CNN
	1    3650 1850
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR014
U 1 1 562D4BE8
P 2350 2000
F 0 "#PWR014" H 2350 1850 50  0001 C CNN
F 1 "VCC" H 2350 2150 50  0000 C CNN
F 2 "" H 2350 2000 60  0000 C CNN
F 3 "" H 2350 2000 60  0000 C CNN
	1    2350 2000
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR015
U 1 1 562D4C41
P 2400 2650
F 0 "#PWR015" H 2400 2500 50  0001 C CNN
F 1 "VCC" H 2400 2800 50  0000 C CNN
F 2 "" H 2400 2650 60  0000 C CNN
F 3 "" H 2400 2650 60  0000 C CNN
	1    2400 2650
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR016
U 1 1 562D4EF2
P 9250 1450
F 0 "#PWR016" H 9250 1300 50  0001 C CNN
F 1 "VCC" H 9250 1600 50  0000 C CNN
F 2 "" H 9250 1450 60  0000 C CNN
F 3 "" H 9250 1450 60  0000 C CNN
	1    9250 1450
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR017
U 1 1 562D4F36
P 9250 2300
F 0 "#PWR017" H 9250 2150 50  0001 C CNN
F 1 "VCC" H 9250 2450 50  0000 C CNN
F 2 "" H 9250 2300 60  0000 C CNN
F 3 "" H 9250 2300 60  0000 C CNN
	1    9250 2300
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR018
U 1 1 562D4F7A
P 9200 3150
F 0 "#PWR018" H 9200 3000 50  0001 C CNN
F 1 "VCC" H 9200 3300 50  0000 C CNN
F 2 "" H 9200 3150 60  0000 C CNN
F 3 "" H 9200 3150 60  0000 C CNN
	1    9200 3150
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR019
U 1 1 562D4FBE
P 9250 4100
F 0 "#PWR019" H 9250 3950 50  0001 C CNN
F 1 "VCC" H 9250 4250 50  0000 C CNN
F 2 "" H 9250 4100 60  0000 C CNN
F 3 "" H 9250 4100 60  0000 C CNN
	1    9250 4100
	1    0    0    -1  
$EndComp
NoConn ~ 5700 2650
NoConn ~ 5700 2750
NoConn ~ 5700 2850
NoConn ~ 5700 2950
NoConn ~ 5700 3050
Text Label 1900 2850 2    60   ~ 0
RESET
$Comp
L VCC #PWR020
U 1 1 562DA3A8
P 1550 950
F 0 "#PWR020" H 1550 800 50  0001 C CNN
F 1 "VCC" H 1550 1100 50  0000 C CNN
F 2 "" H 1550 950 60  0000 C CNN
F 3 "" H 1550 950 60  0000 C CNN
	1    1550 950 
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR021
U 1 1 562DA51C
P 1900 1100
F 0 "#PWR021" H 1900 850 50  0001 C CNN
F 1 "GND" H 1900 950 50  0000 C CNN
F 2 "" H 1900 1100 60  0000 C CNN
F 3 "" H 1900 1100 60  0000 C CNN
	1    1900 1100
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG022
U 1 1 562DA54F
P 1900 1000
F 0 "#FLG022" H 1900 1095 50  0001 C CNN
F 1 "PWR_FLAG" H 1900 1180 50  0000 C CNN
F 2 "" H 1900 1000 60  0000 C CNN
F 3 "" H 1900 1000 60  0000 C CNN
	1    1900 1000
	1    0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG023
U 1 1 562DA775
P 1550 1050
F 0 "#FLG023" H 1550 1145 50  0001 C CNN
F 1 "PWR_FLAG" H 1550 1230 50  0000 C CNN
F 2 "" H 1550 1050 60  0000 C CNN
F 3 "" H 1550 1050 60  0000 C CNN
	1    1550 1050
	1    0    0    1   
$EndComp
Wire Wire Line
	1550 950  1550 1050
$Comp
L GND #PWR024
U 1 1 562DB41D
P 7800 3100
F 0 "#PWR024" H 7800 2850 50  0001 C CNN
F 1 "GND" H 7800 2950 50  0000 C CNN
F 2 "" H 7800 3100 60  0000 C CNN
F 3 "" H 7800 3100 60  0000 C CNN
	1    7800 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 1100 1900 1000
Connection ~ 3750 2000
$Comp
L C C1
U 1 1 562DC51F
P 3700 2450
F 0 "C1" H 3725 2550 50  0000 L CNN
F 1 "100n" H 3725 2350 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 3738 2300 30  0001 C CNN
F 3 "" H 3700 2450 60  0000 C CNN
	1    3700 2450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR025
U 1 1 562DC68E
P 3700 2650
F 0 "#PWR025" H 3700 2400 50  0001 C CNN
F 1 "GND" H 3700 2500 50  0000 C CNN
F 2 "" H 3700 2650 60  0000 C CNN
F 3 "" H 3700 2650 60  0000 C CNN
	1    3700 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 2300 3800 2300
Wire Wire Line
	3700 2600 3700 2650
Wire Wire Line
	3750 1700 3750 2000
$Comp
L CONN_01X02 P11
U 1 1 562DD23C
P 9650 4150
F 0 "P11" H 9650 4300 50  0000 C CNN
F 1 "CONN_E_STOP" V 9750 4150 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 9650 4150 60  0001 C CNN
F 3 "" H 9650 4150 60  0000 C CNN
	1    9650 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	9250 4100 9450 4100
Wire Wire Line
	9250 4200 9450 4200
$EndSCHEMATC
