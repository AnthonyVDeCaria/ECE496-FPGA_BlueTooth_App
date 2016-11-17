#all this code should be the same 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
import ok
import BoardInfo as info
import struct
import matplotlib.pyplot as plt
import sys 
import time


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

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#==================== FPGA Configuration ======================
print("Configuring FPGA...")

#note change to necessary file path later
x = dev.ConfigureFPGA('/media/ming/D/ECE496/Python/fbc_w_ok.bit')

#checking configuration
if (x != 0):
	sys.exit ('FPGA bitfile not found or device is not connected')

#==================== Start Operations ======================

# ____________________
#	assign reset = ep02wireIn[0];
#	assign want_at = ep02wireIn[1];
#	assign begin_connection = ep02wireIn[2];
#	assign user_data_loaded = ep02wireIn[3];
#	assign user_knows_stored = ep02wireIn[4];
#	assign user_data_done = ep02wireIn[5];
#	assign access_RFIFO = ep02wireIn[6];
#	assign user_received_data = ep02wireIn[7];
#	assign finished_with_RFIFO = ep02wireIn[8];
# ____________________

#Start with reset
dev.SetWireInValue( 0x02, 0x0001, 0xffff )
dev.UpdateWireIns()

#reading current state #
dev.UpdateWireOuts()
ep21value = dev.GetWireOutValue( 0x21 )
print('Before start 0x21: %04x' % ep21value)

#list of AT commands
#AT+ORGL
ATO = [0x4154, 0x2b4f, 0x5247, 0x4c0d, 0x0a00]
#AT
AT= [0x4154, 0x0d0a]
#AT+RESET
ATR = [0x4154, 0x2b52, 0x4553, 0x4554, 0x0d0a]
#AT+NAME
ATN = [0x4154, 0x2b4e, 0x414d, 0x450d, 0x0a00]

#variables for flags and counters
count = 0
write = 0
read = 0
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
		elif (command == 'ATN'):
			write = 4
			at = ATN
			print('Write:', command)
		#exit
		elif (command == 'exit'):
			exit = 1
		#read
		else:
			read = 1
			print('Read', command)

	if (write > 0):
		print ("write: ", write)
		# sending in AT command
		while (count < len(at)):
			print('Loading: %04x' % at[count])
			#sending in part of AT command
			dev.SetWireInValue( 0x02, 0x0006, 0xffff )
			dev.UpdateWireIns()

			dev.SetWireInValue(0x01, at[count], 0xffff)
			dev.UpdateWireIns()

			dev.SetWireInValue(0x02, 0x000e, 0xffff)
			dev.UpdateWireIns()
	
			if (count == len(AT)-1):
				#user_knows_stored at the end
				dev.SetWireInValue(0x02, 0x003e, 0xffff)
				dev.UpdateWireIns()
			else:
				#user_knows_stored
				dev.SetWireInValue(0x02, 0x0012, 0xffff)
				dev.UpdateWireIns()

			count += 1

		print("done reading continue")

		timer = 0
		while (timer < 50000000):
			timer += 1

		#reading current state #
		dev.UpdateWireOuts()
		ep21value = dev.GetWireOutValue( 0x21 )
		print('After done loading all data 0x21: %04x' % ep21value)
	
		#ep20 for reading values out
		out = 0
		dev.UpdateWireOuts()
		state = dev.GetWireOutValue( 0x21 ) & 0x000F
		ep29 = dev.GetWireOutValue( 0x29 )
		print('We are in state %x.' % state)
		print('The RFIFO was written %04x times.' % ep29)
		if (ep29 > 1):
			ep29 >> 1
		print('We should read %04x pieces of data.' % ep29)
		ep29 = 4
		while (ep29 > 0):
			#forward
			dev.SetWireInValue( 0x02, 0x0046, 0xffff )
			dev.UpdateWireIns()
	
			dev.UpdateWireOuts()
			out = dev.GetWireOutValue( 0x20 )
			print('reading out: %04x' % out)
			#finished reading segment
			if (ep29 > 0):
				dev.SetWireInValue( 0x02, 0x0086, 0xffff )
				dev.UpdateWireIns()
				ep29 -= 1
			else:
				#finished with AT_FIFO
				dev.SetWireInValue( 0x02, 0x0186, 0xffff )
				dev.UpdateWireIns()

		print("done reading continue")

		dev.UpdateWireOuts()
		ep20value = dev.GetWireOutValue( 0x21 )
		print("\nAfter done with AT")
		print('0x21: %04x' % ep20value)

		dev.UpdateWireOuts()
		ep30value = dev.GetWireOutValue( 0x30 )
		print('0x30: %04x' % ep30value)

	elif (read == 1):
		dev.UpdateWireOuts()
		out = dev.GetWireOutValue( 0x20 )	
		print('reading out: %04x' % out)
	#resetting all flags and counters
	init_flag = 0
	count = 0
	write = 0
	read = 0
	command = ""

#resetting begin (note using reset signal, can use begin_connection set to 0)
dev.SetWireInValue(0x02, 0x0001, 0xffff)
dev.UpdateWireIns()

dev.UpdateWireOuts()
ep21value = dev.GetWireOutValue( 0x21 )
print("\nAfter reset at the end")
print('0x21: %04x' % ep21value)
	

