EESchema Schematic File Version 4
LIBS:magicFlash64-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L magicFlash64-rescue:ATMEGA48-20PU U2
U 1 1 5B16806F
P 7050 5000
F 0 "U2" H 6200 6300 50  0000 L BNN
F 1 "ATMEGA48-20PU" H 7400 3650 50  0000 L BNN
F 2 "Housings_DIP:DIP-28_W7.62mm" H 7050 5000 50  0001 C CIN
F 3 "" H 7050 5000 50  0001 C CNN
	1    7050 5000
	1    0    0    -1  
$EndComp
$Comp
L magicFlash64-rescue:SST39SF040 U3
U 1 1 5B16820D
P 9250 1900
F 0 "U3" H 9350 3200 50  0000 C CNN
F 1 "AM29F040" H 9250 700 50  0000 C CNN
F 2 "Sockets:PLCC32" H 9250 2200 50  0001 C CNN
F 3 "" H 9250 2200 50  0001 C CNN
	1    9250 1900
	1    0    0    -1  
$EndComp
$Comp
L magicFlash64-rescue:27128 U1
U 1 1 5B16855C
P 2300 2800
F 0 "U1" H 2050 3800 50  0000 C CNN
F 1 "ROMSOCKET" H 2300 1800 50  0000 C CNN
F 2 "Housings_DIP:DIP-28_W15.24mm_Socket" H 2300 2800 50  0001 C CNN
F 3 "" H 2300 2800 50  0001 C CNN
	1    2300 2800
	1    0    0    -1  
$EndComp
Text GLabel 3000 1900 2    60   Input ~ 0
D0
Text GLabel 3000 2000 2    60   Input ~ 0
D1
Text GLabel 3000 2100 2    60   Input ~ 0
D2
Text GLabel 3000 2200 2    60   Input ~ 0
D3
Text GLabel 3000 2300 2    60   Input ~ 0
D4
Text GLabel 3000 2400 2    60   Input ~ 0
D5
Text GLabel 3000 2500 2    60   Input ~ 0
D6
Text GLabel 3000 2600 2    60   Input ~ 0
D7
Text GLabel 9850 700  2    60   Input ~ 0
D0
Text GLabel 9850 800  2    60   Input ~ 0
D1
Text GLabel 9850 900  2    60   Input ~ 0
D2
Text GLabel 9850 1000 2    60   Input ~ 0
D3
Text GLabel 9850 1100 2    60   Input ~ 0
D4
Text GLabel 9850 1200 2    60   Input ~ 0
D5
Text GLabel 9850 1300 2    60   Input ~ 0
D6
Text GLabel 9850 1400 2    60   Input ~ 0
D7
Text GLabel 1600 1900 0    60   Input ~ 0
A0
Text GLabel 1600 2000 0    60   Input ~ 0
A1
Text GLabel 1600 2100 0    60   Input ~ 0
A2
Text GLabel 1600 2200 0    60   Input ~ 0
A3
Text GLabel 1600 2300 0    60   Input ~ 0
A4
Text GLabel 1600 2400 0    60   Input ~ 0
A5
Text GLabel 1600 2500 0    60   Input ~ 0
A6
Text GLabel 1600 2600 0    60   Input ~ 0
A7
Text GLabel 1600 2700 0    60   Input ~ 0
A8
Text GLabel 1600 2800 0    60   Input ~ 0
A9
Text GLabel 1600 2900 0    60   Input ~ 0
A10
Text GLabel 1600 3000 0    60   Input ~ 0
A11_A12
Text GLabel 1600 3100 0    60   Input ~ 0
A12
Text GLabel 1600 3200 0    60   Input ~ 0
A13_VCC
$Comp
L power:VCC #PWR01
U 1 1 5B16855D
P 1600 3400
F 0 "#PWR01" H 1600 3250 50  0001 C CNN
F 1 "VCC" H 1600 3550 50  0000 C CNN
F 2 "" H 1600 3400 50  0001 C CNN
F 3 "" H 1600 3400 50  0001 C CNN
	1    1600 3400
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5B16855E
P 1100 4500
F 0 "#PWR02" H 1100 4250 50  0001 C CNN
F 1 "GND" H 1100 4350 50  0000 C CNN
F 2 "" H 1100 4500 50  0001 C CNN
F 3 "" H 1100 4500 50  0001 C CNN
	1    1100 4500
	0    1    1    0   
$EndComp
Text GLabel 8650 3000 0    60   Input ~ 0
OE
Text GLabel 8650 700  0    60   Input ~ 0
A0
Text GLabel 8650 800  0    60   Input ~ 0
A1
Text GLabel 8650 900  0    60   Input ~ 0
A2
Text GLabel 8650 1000 0    60   Input ~ 0
A3
Text GLabel 8650 1100 0    60   Input ~ 0
A4
Text GLabel 8650 1200 0    60   Input ~ 0
A5
Text GLabel 8650 1300 0    60   Input ~ 0
A6
Text GLabel 8650 1400 0    60   Input ~ 0
A7
Text GLabel 8650 1500 0    60   Input ~ 0
A8
Text GLabel 8650 1600 0    60   Input ~ 0
A9
Text GLabel 8650 1700 0    60   Input ~ 0
A10
Text GLabel 8650 1800 0    60   Input ~ 0
A11
Text GLabel 8650 1900 0    60   Input ~ 0
A12
Text GLabel 5850 2000 0    60   Input ~ 0
SEL_A13
Text GLabel 5850 2100 0    60   Input ~ 0
SEL_A14
Text GLabel 5850 2200 0    60   Input ~ 0
SEL_A15
$Comp
L power:VCC #PWR03
U 1 1 5B168562
P 6050 1200
F 0 "#PWR03" H 6050 1050 50  0001 C CNN
F 1 "VCC" H 6050 1350 50  0000 C CNN
F 2 "" H 6050 1200 50  0001 C CNN
F 3 "" H 6050 1200 50  0001 C CNN
	1    6050 1200
	1    0    0    -1  
$EndComp
Text GLabel 4300 3350 0    60   Input ~ 0
SEL_A13
Text GLabel 4300 3450 0    60   Input ~ 0
SEL_A14
Text GLabel 4300 3550 0    60   Input ~ 0
SEL_A15
$Comp
L power:GND #PWR04
U 1 1 5B168563
P 4300 3250
F 0 "#PWR04" H 4300 3000 50  0001 C CNN
F 1 "GND" H 4300 3100 50  0000 C CNN
F 2 "" H 4300 3250 50  0001 C CNN
F 3 "" H 4300 3250 50  0001 C CNN
	1    4300 3250
	0    1    1    0   
$EndComp
Text GLabel 3650 4700 3    60   Input ~ 0
A13
Text GLabel 3900 4600 2    60   Input ~ 0
SEL_A13
$Comp
L magicFlash64-rescue:D D1
U 1 1 5B168564
P 6050 3000
F 0 "D1" H 6050 3100 50  0000 C CNN
F 1 "D" H 6050 2900 50  0000 C CNN
F 2 "Diodes_THT:D_DO-35_SOD27_P2.54mm_Vertical_AnodeUp" H 6050 3000 50  0001 C CNN
F 3 "" H 6050 3000 50  0001 C CNN
	1    6050 3000
	0    -1   -1   0   
$EndComp
$Comp
L magicFlash64-rescue:D D2
U 1 1 5B168565
P 6200 3000
F 0 "D2" H 6200 3100 50  0000 C CNN
F 1 "D" H 6200 2900 50  0000 C CNN
F 2 "Diodes_THT:D_DO-35_SOD27_P2.54mm_Vertical_AnodeUp" H 6200 3000 50  0001 C CNN
F 3 "" H 6200 3000 50  0001 C CNN
	1    6200 3000
	0    -1   -1   0   
$EndComp
$Comp
L magicFlash64-rescue:D D3
U 1 1 5B168566
P 6350 3000
F 0 "D3" H 6350 3100 50  0000 C CNN
F 1 "D" H 6350 2900 50  0000 C CNN
F 2 "Diodes_THT:D_DO-35_SOD27_P2.54mm_Vertical_AnodeUp" H 6350 3000 50  0001 C CNN
F 3 "" H 6350 3000 50  0001 C CNN
	1    6350 3000
	0    -1   -1   0   
$EndComp
Text GLabel 5800 3250 0    60   Input ~ 0
LOROM
$Comp
L power:GND #PWR05
U 1 1 5B168567
P 5700 4350
F 0 "#PWR05" H 5700 4100 50  0001 C CNN
F 1 "GND" H 5700 4200 50  0000 C CNN
F 2 "" H 5700 4350 50  0001 C CNN
F 3 "" H 5700 4350 50  0001 C CNN
	1    5700 4350
	1    0    0    -1  
$EndComp
$Comp
L magicFlash64-rescue:C C1
U 1 1 5B168568
P 5700 4200
F 0 "C1" H 5725 4300 50  0000 L CNN
F 1 "100n" H 5725 4100 50  0000 L CNN
F 2 "Capacitors_THT:C_Disc_D3.4mm_W2.1mm_P2.50mm" H 5738 4050 50  0001 C CNN
F 3 "" H 5700 4200 50  0001 C CNN
	1    5700 4200
	-1   0    0    1   
$EndComp
Text GLabel 8750 4450 2    60   Input ~ 0
SEL_A13
Text GLabel 7950 5750 2    60   Input ~ 0
SEL_A14
Text GLabel 7950 5850 2    60   Input ~ 0
SEL_A15
Text GLabel 7950 5650 2    60   Input ~ 0
RESTORE
Text GLabel 7950 4050 2    60   Input ~ 0
RESET
Text GLabel 2650 5400 0    60   Input ~ 0
RESTORE
Text GLabel 3800 5300 0    60   Input ~ 0
RESET
$Comp
L magicFlash64-rescue:CONN_01X03 J3
U 1 1 5B168569
P 5200 5350
F 0 "J3" H 5200 5550 50  0000 C CNN
F 1 "1x3" V 5300 5350 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03_Pitch2.54mm" H 5200 5350 50  0001 C CNN
F 3 "" H 5200 5350 50  0001 C CNN
	1    5200 5350
	1    0    0    -1  
$EndComp
$Comp
L magicFlash64-rescue:R R1
U 1 1 5B16856A
P 4650 5250
F 0 "R1" V 4730 5250 50  0000 C CNN
F 1 "1k" V 4650 5250 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0204_L3.6mm_D1.6mm_P2.54mm_Vertical" V 4580 5250 50  0001 C CNN
F 3 "" H 4650 5250 50  0001 C CNN
	1    4650 5250
	0    1    1    0   
$EndComp
$Comp
L magicFlash64-rescue:R R2
U 1 1 5B16856B
P 4650 5450
F 0 "R2" V 4730 5450 50  0000 C CNN
F 1 "1k" V 4650 5450 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0204_L3.6mm_D1.6mm_P2.54mm_Vertical" V 4580 5450 50  0001 C CNN
F 3 "" H 4650 5450 50  0001 C CNN
	1    4650 5450
	0    1    1    0   
$EndComp
Text GLabel 4500 5450 0    60   Input ~ 0
LED
$Comp
L power:GND #PWR06
U 1 1 5B16856C
P 5000 5350
F 0 "#PWR06" H 5000 5100 50  0001 C CNN
F 1 "GND" H 5000 5200 50  0000 C CNN
F 2 "" H 5000 5350 50  0001 C CNN
F 3 "" H 5000 5350 50  0001 C CNN
	1    5000 5350
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR07
U 1 1 5B16856D
P 4500 5250
F 0 "#PWR07" H 4500 5100 50  0001 C CNN
F 1 "VCC" H 4500 5400 50  0000 C CNN
F 2 "" H 4500 5250 50  0001 C CNN
F 3 "" H 4500 5250 50  0001 C CNN
	1    4500 5250
	0    -1   -1   0   
$EndComp
$Comp
L magicFlash64-rescue:Jumper_NC_Dual JP1
U 1 1 5B16856E
P 1350 4500
F 0 "JP1" H 1400 4400 50  0000 L CNN
F 1 "1x3" H 1350 4600 50  0000 C BNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03_Pitch2.54mm" H 1350 4500 50  0001 C CNN
F 3 "" H 1350 4500 50  0001 C CNN
	1    1350 4500
	1    0    0    -1  
$EndComp
$Comp
L magicFlash64-rescue:Jumper_NC_Dual JP2
U 1 1 5B16856F
P 1350 6650
F 0 "JP2" H 1400 6550 50  0000 L CNN
F 1 "1x3" H 1350 6750 50  0000 C BNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03_Pitch2.54mm" H 1350 6650 50  0001 C CNN
F 3 "" H 1350 6650 50  0001 C CNN
	1    1350 6650
	1    0    0    -1  
$EndComp
$Comp
L magicFlash64-rescue:Jumper_NC_Dual JP3
U 1 1 5B168570
P 1400 5700
F 0 "JP3" H 1450 5600 50  0000 L CNN
F 1 "1x3" H 1400 5800 50  0000 C BNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03_Pitch2.54mm" H 1400 5700 50  0001 C CNN
F 3 "" H 1400 5700 50  0001 C CNN
	1    1400 5700
	1    0    0    -1  
$EndComp
Text GLabel 1350 6750 3    60   Input ~ 0
A13_VCC
Text GLabel 1400 5800 3    60   Input ~ 0
A11_A12
Text GLabel 1150 5700 0    60   Input ~ 0
A11
Text GLabel 1100 6650 0    60   Input ~ 0
A13
Text GLabel 1600 4500 2    60   Input ~ 0
A11
Text GLabel 1650 5700 2    60   Input ~ 0
A12
$Comp
L power:VCC #PWR08
U 1 1 5B168571
P 1600 6650
F 0 "#PWR08" H 1600 6500 50  0001 C CNN
F 1 "VCC" H 1600 6800 50  0000 C CNN
F 2 "" H 1600 6650 50  0001 C CNN
F 3 "" H 1600 6650 50  0001 C CNN
	1    1600 6650
	0    1    1    0   
$EndComp
Text GLabel 5850 2300 0    60   Input ~ 0
SEL_A16
Text GLabel 5850 2400 0    60   Input ~ 0
SEL_A17
$Comp
L magicFlash64-rescue:D D4
U 1 1 5B168574
P 6500 3000
F 0 "D4" H 6500 3100 50  0000 C CNN
F 1 "D" H 6500 2900 50  0000 C CNN
F 2 "Diodes_THT:D_DO-35_SOD27_P2.54mm_Vertical_AnodeUp" H 6500 3000 50  0001 C CNN
F 3 "" H 6500 3000 50  0001 C CNN
	1    6500 3000
	0    -1   -1   0   
$EndComp
$Comp
L magicFlash64-rescue:D D5
U 1 1 5B168575
P 6650 3000
F 0 "D5" H 6650 3100 50  0000 C CNN
F 1 "D" H 6650 2900 50  0000 C CNN
F 2 "Diodes_THT:D_DO-35_SOD27_P2.54mm_Vertical_AnodeUp" H 6650 3000 50  0001 C CNN
F 3 "" H 6650 3000 50  0001 C CNN
	1    6650 3000
	0    -1   -1   0   
$EndComp
Text GLabel 4300 3650 0    60   Input ~ 0
SEL_A16
Text GLabel 4300 3750 0    60   Input ~ 0
SEL_A17
Text GLabel 7950 5950 2    60   Input ~ 0
SEL_A16
Text GLabel 7950 6050 2    60   Input ~ 0
SEL_A17
Text GLabel 7950 5200 2    60   Input ~ 0
A12
Text GLabel 7950 5100 2    60   Input ~ 0
A11
$Comp
L power:GND #PWR09
U 1 1 5B168576
P 8650 2900
F 0 "#PWR09" H 8650 2650 50  0001 C CNN
F 1 "GND" H 8650 2750 50  0000 C CNN
F 2 "" H 8650 2900 50  0001 C CNN
F 3 "" H 8650 2900 50  0001 C CNN
	1    8650 2900
	0    1    1    0   
$EndComp
Text GLabel 7950 4700 2    60   Input ~ 0
A0
Text GLabel 7950 3950 2    60   Input ~ 0
LED
$Comp
L magicFlash64-rescue:Jumper_NC_Dual JP5
U 1 1 5B168577
P 3650 4600
F 0 "JP5" H 3700 4500 50  0000 L CNN
F 1 "1x3" H 3650 4700 50  0000 C BNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03_Pitch2.54mm" H 3650 4600 50  0001 C CNN
F 3 "" H 3650 4600 50  0001 C CNN
	1    3650 4600
	1    0    0    -1  
$EndComp
Text GLabel 3400 4600 0    60   Input ~ 0
LOROM
Text GLabel 5850 2500 0    60   Input ~ 0
SEL_A18
$Comp
L magicFlash64-rescue:D D6
U 1 1 5B16857A
P 6800 3000
F 0 "D6" H 6800 3100 50  0000 C CNN
F 1 "D" H 6800 2900 50  0000 C CNN
F 2 "Diodes_THT:D_DO-35_SOD27_P2.54mm_Vertical_AnodeUp" H 6800 3000 50  0001 C CNN
F 3 "" H 6800 3000 50  0001 C CNN
	1    6800 3000
	0    -1   -1   0   
$EndComp
Text GLabel 7950 6150 2    60   Input ~ 0
SEL_A18
$Comp
L power:VCC #PWR010
U 1 1 5B168580
P 5600 3850
F 0 "#PWR010" H 5600 3700 50  0001 C CNN
F 1 "VCC" H 5600 4000 50  0000 C CNN
F 2 "" H 5600 3850 50  0001 C CNN
F 3 "" H 5600 3850 50  0001 C CNN
	1    5600 3850
	1    0    0    -1  
$EndComp
Text GLabel 7950 5000 2    60   Input ~ 0
A10
Text GLabel 7950 4900 2    60   Input ~ 0
A9
Text GLabel 7950 4800 2    60   Input ~ 0
A8
$Comp
L magicFlash64-rescue:Conn_01x07 J2
U 1 1 5B168583
P 4500 3550
F 0 "J2" H 4500 3950 50  0000 C CNN
F 1 "1x7" H 4500 3150 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x07_Pitch2.54mm" H 4500 3550 50  0001 C CNN
F 3 "" H 4500 3550 50  0001 C CNN
	1    4500 3550
	1    0    0    -1  
$EndComp
Text GLabel 4300 3850 0    60   Input ~ 0
SEL_A18
Wire Wire Line
	5850 2000 6050 2000
Wire Wire Line
	5850 2100 6200 2100
Wire Wire Line
	5850 2200 6350 2200
Wire Wire Line
	6050 1600 6050 2000
Connection ~ 6050 2000
Wire Wire Line
	6200 1850 6200 2100
Connection ~ 6200 2100
Wire Wire Line
	6350 1800 6350 2200
Connection ~ 6350 2200
Wire Wire Line
	5800 3250 6050 3250
Wire Wire Line
	6350 3250 6350 3150
Wire Wire Line
	6200 3150 6200 3250
Connection ~ 6200 3250
Wire Wire Line
	6050 3150 6050 3250
Connection ~ 6050 3250
Wire Wire Line
	4800 5250 5000 5250
Wire Wire Line
	4800 5450 5000 5450
Wire Wire Line
	5850 2300 6500 2300
Wire Wire Line
	6650 3250 6650 3150
Connection ~ 6350 3250
Wire Wire Line
	6500 3150 6500 3250
Connection ~ 6500 3250
Wire Wire Line
	6500 1750 6500 2300
Connection ~ 6500 2300
Wire Wire Line
	6650 1700 6650 2400
Connection ~ 6650 2400
Wire Wire Line
	5850 2500 6800 2500
Wire Wire Line
	6800 1650 6800 2500
Connection ~ 6800 2500
Wire Wire Line
	6800 3250 6800 3150
Connection ~ 6650 3250
Wire Wire Line
	5850 2400 6650 2400
Text GLabel 1600 3300 0    60   Input ~ 0
ROM_A14
Text GLabel 4050 2550 0    60   Input ~ 0
ROM_A14
$Comp
L magicFlash64-rescue:Jumper JP4
U 1 1 5B168585
P 4350 2550
F 0 "JP4" H 4350 2700 50  0000 C CNN
F 1 "1x2" H 4350 2470 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02_Pitch2.54mm" H 4350 2550 50  0001 C CNN
F 3 "" H 4350 2550 50  0001 C CNN
	1    4350 2550
	1    0    0    -1  
$EndComp
Text GLabel 4650 2550 2    60   Input ~ 0
SEL_A14
Wire Wire Line
	5600 3850 5700 3850
Wire Wire Line
	5850 3850 5850 4150
Wire Wire Line
	5850 4150 6050 4150
Connection ~ 5850 3850
$Comp
L power:GND #PWR011
U 1 1 5B16A72B
P 5900 6200
F 0 "#PWR011" H 5900 5950 50  0001 C CNN
F 1 "GND" H 5900 6050 50  0000 C CNN
F 2 "" H 5900 6200 50  0001 C CNN
F 3 "" H 5900 6200 50  0001 C CNN
	1    5900 6200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5900 6200 5900 6150
Wire Wire Line
	5900 6050 6050 6050
Wire Wire Line
	6050 6150 5900 6150
Connection ~ 5900 6150
NoConn ~ 6050 4450
Text GLabel 7950 3850 2    60   Input ~ 0
RW
Text GLabel 8750 4250 2    60   Input ~ 0
WE_EN
Text GLabel 8650 2700 0    60   Input ~ 0
WE
Text GLabel 3800 5500 0    60   Input ~ 0
RW
Wire Wire Line
	5700 4050 5700 3850
Connection ~ 5700 3850
Text GLabel 1600 3700 0    60   Input ~ 0
OE
Text GLabel 1600 3600 0    60   Input ~ 0
GND_A11
Text GLabel 1350 4600 3    60   Input ~ 0
GND_A11
$Comp
L magicFlash64-rescue:CONN_01X04 J4
U 1 1 5BFD9C3B
P 9450 5400
F 0 "J4" H 9450 5650 50  0000 C CNN
F 1 "1x4" V 9550 5400 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x04_Pitch2.54mm" H 9450 5400 50  0001 C CNN
F 3 "" H 9450 5400 50  0001 C CNN
	1    9450 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7950 5450 8850 5450
Wire Wire Line
	9250 5550 8650 5550
$Comp
L power:GND #PWR013
U 1 1 5BFDA870
P 9250 5250
F 0 "#PWR013" H 9250 5000 50  0001 C CNN
F 1 "GND" H 9250 5100 50  0000 C CNN
F 2 "" H 9250 5250 50  0001 C CNN
F 3 "" H 9250 5250 50  0001 C CNN
	1    9250 5250
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR014
U 1 1 5BFDB18C
P 8850 6000
F 0 "#PWR014" H 8850 5850 50  0001 C CNN
F 1 "VCC" H 8850 6150 50  0000 C CNN
F 2 "" H 8850 6000 50  0001 C CNN
F 3 "" H 8850 6000 50  0001 C CNN
	1    8850 6000
	-1   0    0    1   
$EndComp
$Comp
L magicFlash64-rescue:R R13
U 1 1 5C12D3B0
P 3250 5400
F 0 "R13" V 3330 5400 50  0000 C CNN
F 1 "270" V 3250 5400 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0204_L3.6mm_D1.6mm_P2.54mm_Vertical" V 3180 5400 50  0001 C CNN
F 3 "" H 3250 5400 50  0001 C CNN
	1    3250 5400
	0    1    1    0   
$EndComp
Wire Wire Line
	3400 5400 3800 5400
Wire Wire Line
	3100 5400 2650 5400
Text Notes 1550 4850 0    60   ~ 0
1-2 28pin\n2-3 24pin
Text Notes 1550 6050 0    60   ~ 0
1-2 28pin\n2-3 24pin
Text Notes 1500 7000 0    60   ~ 0
1-2 28pin\n2-3 24pin
Text Notes 3800 5100 0    60   ~ 0
1-2 28pin with lo ROM (BASIC)\n2-3 28pin without lo ROM (16k slots)\nset to 1-2 for C64
Text Notes 3600 2850 0    60   ~ 0
set 32k slots (requires JP5 to 2-3)\nleave empty for C64
$Comp
L magicFlash64-rescue:R_Network06 RN1
U 1 1 5C7A4BAC
P 6350 1400
F 0 "RN1" V 5950 1400 50  0000 C CNN
F 1 "10k" V 6650 1400 50  0000 C CNN
F 2 "Resistors_THT:R_Array_SIP7" V 6725 1400 50  0001 C CNN
F 3 "" H 6350 1400 50  0001 C CNN
	1    6350 1400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6150 1600 6150 1850
Wire Wire Line
	6150 1850 6200 1850
Wire Wire Line
	6350 1800 6250 1800
Wire Wire Line
	6250 1800 6250 1600
Wire Wire Line
	6500 1750 6350 1750
Wire Wire Line
	6350 1750 6350 1600
Wire Wire Line
	6650 1700 6450 1700
Wire Wire Line
	6450 1700 6450 1600
Wire Wire Line
	6800 1650 6550 1650
Wire Wire Line
	6550 1650 6550 1600
Text GLabel 7950 5300 2    60   Input ~ 0
RST
Wire Wire Line
	8850 6000 8850 5950
Wire Wire Line
	8650 6000 8650 5950
$Comp
L magicFlash64-rescue:R R11
U 1 1 5BFDAEAA
P 8650 5800
F 0 "R11" V 8730 5800 50  0000 C CNN
F 1 "4.7K" V 8650 5800 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0204_L3.6mm_D1.6mm_P2.54mm_Vertical" V 8580 5800 50  0001 C CNN
F 3 "" H 8650 5800 50  0001 C CNN
	1    8650 5800
	-1   0    0    1   
$EndComp
$Comp
L magicFlash64-rescue:R R10
U 1 1 5BFDAAF2
P 8850 5800
F 0 "R10" V 8930 5800 50  0000 C CNN
F 1 "4.7K" V 8850 5800 50  0000 C CNN
F 2 "Resistors_THT:R_Axial_DIN0204_L3.6mm_D1.6mm_P2.54mm_Vertical" V 8780 5800 50  0001 C CNN
F 3 "" H 8850 5800 50  0001 C CNN
	1    8850 5800
	-1   0    0    1   
$EndComp
$Comp
L magicFlash64-rescue:Conn_02x03_Odd_Even J5
U 1 1 5C7AB62A
P 10100 3600
F 0 "J5" H 10150 3800 50  0000 C CNN
F 1 "AVR ISP" H 10150 3400 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03_Pitch2.54mm" H 10100 3600 50  0001 C CNN
F 3 "" H 10100 3600 50  0001 C CNN
	1    10100 3600
	1    0    0    -1  
$EndComp
Text GLabel 9900 3500 0    60   Input ~ 0
MISO
Text GLabel 9900 3600 0    60   Input ~ 0
SCK
Text GLabel 9900 3700 0    60   Input ~ 0
RST
Text GLabel 10400 3600 2    60   Input ~ 0
MOSI
$Comp
L power:VCC #PWR018
U 1 1 5C7AC077
P 10400 3500
F 0 "#PWR018" H 10400 3350 50  0001 C CNN
F 1 "VCC" H 10400 3650 50  0000 C CNN
F 2 "" H 10400 3500 50  0001 C CNN
F 3 "" H 10400 3500 50  0001 C CNN
	1    10400 3500
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR019
U 1 1 5C7AC0EB
P 10400 3700
F 0 "#PWR019" H 10400 3450 50  0001 C CNN
F 1 "GND" H 10400 3550 50  0000 C CNN
F 2 "" H 10400 3700 50  0001 C CNN
F 3 "" H 10400 3700 50  0001 C CNN
	1    10400 3700
	0    -1   -1   0   
$EndComp
Text GLabel 9050 4050 2    60   Input ~ 0
MOSI
Wire Wire Line
	9050 4050 8950 4050
Wire Wire Line
	8950 4050 8950 4150
Connection ~ 8950 4150
Text GLabel 8750 4350 2    60   Input ~ 0
MISO
Wire Wire Line
	8750 4250 8600 4250
Wire Wire Line
	8750 4350 8600 4350
Wire Wire Line
	8600 4350 8600 4250
Connection ~ 8600 4250
Wire Wire Line
	8650 6000 8850 6000
Wire Wire Line
	8850 5650 8850 5450
Connection ~ 8850 5450
Wire Wire Line
	8650 5650 8650 5550
Connection ~ 8650 5550
$Comp
L power:VCC #PWR020
U 1 1 5C7AE889
P 9100 5350
F 0 "#PWR020" H 9100 5200 50  0001 C CNN
F 1 "VCC" H 9100 5500 50  0000 C CNN
F 2 "" H 9100 5350 50  0001 C CNN
F 3 "" H 9100 5350 50  0001 C CNN
	1    9100 5350
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9100 5350 9250 5350
Text GLabel 8750 4550 2    60   Input ~ 0
SCK
Wire Wire Line
	7950 4350 8450 4350
Wire Wire Line
	8450 4350 8450 4450
Wire Wire Line
	8450 4450 8750 4450
Wire Wire Line
	8450 4550 8750 4550
Connection ~ 8450 4450
Wire Wire Line
	6050 2000 8650 2000
Wire Wire Line
	6050 2000 6050 2850
Wire Wire Line
	6200 2100 8650 2100
Wire Wire Line
	6200 2100 6200 2850
Wire Wire Line
	6350 2200 8650 2200
Wire Wire Line
	6350 2200 6350 2850
Wire Wire Line
	6200 3250 6350 3250
Wire Wire Line
	6050 3250 6200 3250
Wire Wire Line
	6350 3250 6500 3250
Wire Wire Line
	6500 3250 6650 3250
Wire Wire Line
	6500 2300 8650 2300
Wire Wire Line
	6500 2300 6500 2850
Wire Wire Line
	6650 2400 6650 2850
Wire Wire Line
	6650 2400 8650 2400
Wire Wire Line
	6800 2500 8650 2500
Wire Wire Line
	6800 2500 6800 2850
Wire Wire Line
	6650 3250 6800 3250
Wire Wire Line
	5850 3850 6050 3850
Wire Wire Line
	5900 6150 5900 6050
Wire Wire Line
	5700 3850 5850 3850
Wire Wire Line
	8950 4150 9450 4150
Wire Wire Line
	8600 4250 7950 4250
Wire Wire Line
	8850 5450 9250 5450
Wire Wire Line
	8650 5550 7950 5550
Wire Wire Line
	8450 4450 8450 4550
Text Label 9100 5450 0    60   ~ 0
SCL
Text Label 9100 5550 0    60   ~ 0
SDA
Wire Wire Line
	7950 4150 8950 4150
Text GLabel 9450 4150 2    60   Input ~ 0
OE
Text GLabel 7950 4450 2    60   Input ~ 0
DOT_CLK
Text GLabel 7950 4550 2    60   Input ~ 0
PHI2
$Comp
L Connector_Generic:Conn_01x05 J1
U 1 1 5C9A2AF8
P 4000 5500
F 0 "J1" H 4079 5542 50  0000 L CNN
F 1 "1x5" H 4079 5451 50  0000 L CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x05_Pitch2.54mm" H 4000 5500 50  0001 C CNN
F 3 "~" H 4000 5500 50  0001 C CNN
	1    4000 5500
	1    0    0    -1  
$EndComp
Text GLabel 3800 5600 0    60   Input ~ 0
DOT_CLK
Text GLabel 3800 5700 0    60   Input ~ 0
PHI2
$Comp
L 74xx:74LS138 U4
U 1 1 5C9A6EE2
P 4150 6900
F 0 "U4" H 3900 7350 50  0000 C CNN
F 1 "74LS138" H 4400 6300 50  0000 C CNN
F 2 "Housings_DIP:DIP-16_W7.62mm_Socket" H 4150 6900 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS138" H 4150 6900 50  0001 C CNN
	1    4150 6900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR015
U 1 1 5C9A71BE
P 3550 7400
F 0 "#PWR015" H 3550 7150 50  0001 C CNN
F 1 "GND" H 3550 7250 50  0000 C CNN
F 2 "" H 3550 7400 50  0001 C CNN
F 3 "" H 3550 7400 50  0001 C CNN
	1    3550 7400
	1    0    0    -1  
$EndComp
Wire Wire Line
	3550 7400 3550 7300
Wire Wire Line
	3550 7300 3650 7300
Wire Wire Line
	3650 7200 3550 7200
Wire Wire Line
	3550 7200 3550 7300
Connection ~ 3550 7300
$Comp
L power:VCC #PWR012
U 1 1 5C9AAEC1
P 3550 7100
F 0 "#PWR012" H 3550 6950 50  0001 C CNN
F 1 "VCC" H 3550 7250 50  0000 C CNN
F 2 "" H 3550 7100 50  0001 C CNN
F 3 "" H 3550 7100 50  0001 C CNN
	1    3550 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	3550 7100 3650 7100
$Comp
L power:GND #PWR017
U 1 1 5C9AD3AE
P 4150 7600
F 0 "#PWR017" H 4150 7350 50  0001 C CNN
F 1 "GND" H 4150 7450 50  0000 C CNN
F 2 "" H 4150 7600 50  0001 C CNN
F 3 "" H 4150 7600 50  0001 C CNN
	1    4150 7600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR021
U 1 1 5C9AD69F
P 4550 6200
F 0 "#PWR021" H 4550 5950 50  0001 C CNN
F 1 "GND" H 4550 6050 50  0000 C CNN
F 2 "" H 4550 6200 50  0001 C CNN
F 3 "" H 4550 6200 50  0001 C CNN
	1    4550 6200
	0    -1   -1   0   
$EndComp
$Comp
L magicFlash64-rescue:C C2
U 1 1 5C9AD6A5
P 4400 6200
F 0 "C2" H 4425 6300 50  0000 L CNN
F 1 "100n" H 4425 6100 50  0000 L CNN
F 2 "Capacitors_THT:C_Disc_D3.4mm_W2.1mm_P2.50mm" H 4438 6050 50  0001 C CNN
F 3 "" H 4400 6200 50  0001 C CNN
	1    4400 6200
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR016
U 1 1 5C9AD6AB
P 4150 6100
F 0 "#PWR016" H 4150 5950 50  0001 C CNN
F 1 "VCC" H 4150 6250 50  0000 C CNN
F 2 "" H 4150 6100 50  0001 C CNN
F 3 "" H 4150 6100 50  0001 C CNN
	1    4150 6100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4150 6100 4150 6200
Wire Wire Line
	4250 6200 4150 6200
Connection ~ 4150 6200
Wire Wire Line
	4150 6200 4150 6300
Text GLabel 3650 6600 0    60   Input ~ 0
PHI2
Text GLabel 4650 6700 2    60   Input ~ 0
WE
Text GLabel 3650 6800 0    60   Input ~ 0
WE_EN
Text GLabel 3650 6700 0    60   Input ~ 0
RW
NoConn ~ 4650 6600
NoConn ~ 4650 6800
NoConn ~ 4650 6900
NoConn ~ 4650 7000
NoConn ~ 4650 7100
NoConn ~ 4650 7200
NoConn ~ 4650 7300
$EndSCHEMATC
