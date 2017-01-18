import ok
import BoardInfo as info
import struct
import matplotlib.pyplot as plt
import sys 
import time

import constants as con
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
x = dev.ConfigureFPGA('../Python/hm_10.bit')
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

#get rid of this!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#list of AT commands
#AT+ORGL
ATO = [0x4154, 0x2b4f, 0x5247, 0x4c00]
#AT
AT = [0x4154]
#AT+RESET
ATR = [0x4154, 0x2b52, 0x4553, 0x4554]
#AT+NAME=BU
ATNB = [0x4154, 0x2b4e, 0x414d, 0x453D, 0x4255]
#AT+NAME=
ATNU = [0x4154, 0x2b4e, 0x414d, 0x453D]
########################################################

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

		'''
		#write in certain AT command
		if (command != ''):
			write = 1
			at = ascii_command(command)
			print('Write:', command)
		''' 
		#specific commands, may not be useful later
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
			at = ATNU
			print('Write:', command)
			name = raw_input('Enter name: ')
			index = 4
			for char in name:
				i = lib.convert(char)
		elif (command == "display"):
			write == 0
			lib.display_all_Wire_Outs(dev)
		#exit
		elif (command == 'exit'):
			exit = 1
		#reading while polling for command, or No AT Commands
		else:
			write = -1

	#AT Command sent in
	if (write != 0):
		#Start with reset
		lib.reset(dev)
		
	if (write > 0):
		print("Beginning to send AT Command ", at ,"...")
		AT_w.send_AT_command_to_BTM(dev, at, con.Bluetooth.HM_10)
		print("Done sending AT Command - continue.")
		
		lib.display_all_Wire_Outs(dev)
		
		print('Waiting for Response...')
		# POLL {
		state = lib.read_state(dev) & 0x00FF
		lib.display_all_Wire_Outs(dev)
		while (state <= 0x0088):
			time.sleep(0.01)
			state = lib.read_state(dev) & 0x00FF
			lib.display_all_Wire_Outs(dev)
		# } POLL
		print("Received Response.")

		print('Reading Response...')
		AT_r.read_and_display_AT_response(dev)
		print("Done reading.")
		
		lib.display_all_Wire_Outs(dev)
		lib.clear_wire_ins(dev)

		
	#no AT commands
	elif (write == -1):
		lib.turn_on_datastream(dev)
		
	#resetting all flags and counters
	init_flag = 0
	count = 0
	write = 0
	command = ""

#resetting begin
lib.reset(dev)

lib.clear_wire_ins(dev)

#Read all wire outs
lib.display_all_Wire_Outs(dev)
