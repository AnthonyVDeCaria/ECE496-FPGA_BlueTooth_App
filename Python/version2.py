import ok
import BoardInfo as info
import struct
import matplotlib.pyplot as plt
import sys 
import time

import library as lib
import AT_read as AT_r
import AT_write as AT_w

dev = ok.FrontPanel()
pll = ok.PLL22393()
ClkSrc = info.ClkSrc
Clk = info.Clk

#==================== Open Device ======================
# open the device
# can provide a string with the serial number, or an empty string to open the first device found
# one of our serial numbers is 12290003NA
dev.OpenBySerial('')

# get device information
info.GetDeviceInfo(dev)

#==================== PLL Configuration ======================
print('Setting clocks...')
clkA = 0.5

dividerA = int(50.0/float(clkA))
dev.LoadDefaultPLLConfiguration
pll.SetPLLParameters(0, 50, 48, 1) # 50MHz
pll.SetOutputSource(Clk.A, ClkSrc.PLL0_0)
pll.SetOutputDivider(Clk.A, dividerA)
pll.SetOutputEnable(Clk.A, 1)
dev.SetPLL22393Configuration(pll)

info.GetPLLInfo(pll)
info.GetClkInfo(pll)

#==================== FPGA Configuration ======================
print("Configuring FPGA...")

#note change to necessary file path later
x = dev.ConfigureFPGA('../Python/HC_05.bit')
#path will be different

#checking configuration
if (x != 0):
	sys.exit ('FPGA bitfile not found or device is not connected')

#==================== Start Operations ======================

# ____________________
#	assign reset = ep02wireIn[0];
#	assign access_datastream = ep02wireIn[1];
#	assign want_at = ep02wireIn[2];
#	assign user_data_loaded = ep02wireIn[3];
#	assign user_knows_stored = ep02wireIn[4];
#	assign user_data_done = ep02wireIn[5];
#	assign access_RFIFO = ep02wireIn[6];
#	assign user_received_data = ep02wireIn[7];
#	assign finished_with_RFIFO = ep02wireIn[8];
# ____________________

#Start with reset
lib.reset(dev)

#reading current state #
state = lib.read_state(dev)
print('Before start 0x25: %04x' % state)

#list of AT commands
#AT+ORGL
ATO = [0x4154, 0x2b4f, 0x5247, 0x4c0d, 0x0a00]
#AT
AT= [0x4154, 0x0d0a]
#AT+RESET
ATR = [0x4154, 0x2b52, 0x4553, 0x4554, 0x0d0a]
#AT+NAME=BU
ATNB = [0x4154, 0x2b4e, 0x414d, 0x453D, 0x4255, 0x0d0a]
#AT+NAME=
ATNU = [0x4154, 0x2b4e, 0x414d, 0x453D]

#variables for flags and counters
count = 0
write = 0
exit = 0
command = ''

#using loop to continue reading and writing to Bluetooth
while (exit == 0):
	#polling for AT command
	while (command == ""):
		command = raw_input('Enter command: ')
		print('Command:', command)

		#write in certain AT command
		if (command == 'AT'):
			write = 1
			at = AT
			print('Write:', command)
		elif (command == 'ATO'):
			write = 2
			at = ATO
			print('Write:', command)
		elif (command == 'ATR'):
			write = 3
			at = ATR
			print('Write:', command)
		elif (command == 'ATNB'):
			write = 4
			at = ATNB
			print('Write:', command)
		elif (command == 'ATNU'):
			write = 4
			at = ATN
			print('Write:', command)
			name = raw_input('Enter name: ')
			index = 4
			for char in name:
				i = lib.convert(char)	
		#exit
		elif (command == 'exit'):
			exit = 1
		#reading while polling for command, or No AT Commands
		else:
			write = -1

	#AT Command sent in
	if (write > 0):
		print ("write:", at)

		#Start with reset
		lib.reset(dev)

		# sending in AT command
		while (count < len(at)):
			print('Loading: %04x' % at[count])

			#sending in part of AT command
			AT_w.load_AT_byte(dev, at[count])
	
			if (count == len(at)-1):
				AT_w.alert_FPGA_done_AT_command(dev)
			else:
				AT_w.alert_FPGA_more_to_send(dev)

			count += 1

		print("done sending AT, continue")

		#reading current state#
		#should be passing into Rest_Transmission from Load Transmission
		#don't need to worry about all data sent, bt_done, uart_timer_done

		state = lib.read_state(dev)
		
		while (state == 0x0055):
			timer = 0
			while (timer < 50000000):
				timer += 1
			state = lib.read_state(dev)

		AT_r.read_and_display_AT_response(dev)

		print("Done reading - continue")
		#lib.datastream_toggle(dev, False)

	#no AT commands
	elif (write == -1):
		#Start with reset
		lib.reset(dev)

		lib.datastream_toggle(dev, True)

		
	#resetting all flags and counters
	init_flag = 0
	count = 0
	write = 0
	command = ""

#resetting begin (note using reset signal, can use begin_connection set to 0)
lib.reset(dev)

lib.datastream_toggle(dev, False)

#Read all wire outs
	

