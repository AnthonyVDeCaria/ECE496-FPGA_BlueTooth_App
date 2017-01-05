#convert char to ascii int
def convert(text):
    return (hex(ord(char)))

#main function
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
x = dev.ConfigureFPGA('../Python/HC_05.bit')
#path will be different

#checking configuration
if (x != 0):
	sys.exit ('FPGA bitfile not found or device is not connected')

#==================== Start Operations ======================

# ____________________
#	assign reset = ep02wireIn[0];
#	assign want_at = ep02wireIn[1];
#	assign begin_connection = ep02wireIn[2]; Dead
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
ep25value = dev.GetWireOutValue( 0x25 )
print('Before start 0x25: %04x' % ep25value)

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

#NAT no AT commands

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
				i = convert(char)	
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
		dev.SetWireInValue( 0x02, 0x0001, 0xffff )
		dev.UpdateWireIns()

		# sending in AT command
		while (count < len(at)):
			print('Loading: %04x' % at[count])
			#sending in part of AT command
			#want_at = 1
			dev.SetWireInValue( 0x02, 0x0006, 0xffff )
			dev.UpdateWireIns()

			#part of AT command
			dev.SetWireInValue(0x01, at[count], 0xffff)
			dev.UpdateWireIns()

			#user_data_loaded = 1, want_at = 1
			dev.SetWireInValue(0x02, 0x000e, 0xffff)
			dev.UpdateWireIns()
	
			if (count == len(at)-1):
				#finished sending in AT command (user_knows_stored + user_data_done)
				dev.SetWireInValue(0x02, 0x003e, 0xffff)
				dev.UpdateWireIns()
			else:
				#not finished yet (user_knows_stored + !user_data_done )
				dev.SetWireInValue(0x02, 0x0012, 0xffff)
				dev.UpdateWireIns()

			count += 1

		print("done sending AT, continue")

		#reading current state#
		#should be passing into Rest_Transmission from Load Transmission
		#don't need to worry about all data sent, bt_done, uart_timer_done
		
		dev.UpdateWireOuts()
		out = 0
		state = dev.GetWireOutValue( 0x25 )
		times_RFIFO_written = dev.GetWireOutValue( 0x21 )
		times_to_read_RFIFO = dev.GetWireOutValue( 0x22 )
		
		print('We are in state %04x.' % state)
		print('The RFIFO was written %04x times.' % times_RFIFO_written)
		print('We should read %04x pieces of data.' % times_to_read_RFIFO)
		
		while (state == 0x0055):
			timer = 0
			while (timer < 50000000):
				timer += 1
			
			dev.UpdateWireOuts()
			state = dev.GetWireOutValue( 0x25 )
			times_RFIFO_written = dev.GetWireOutValue( 0x21 )
			times_to_read_RFIFO = dev.GetWireOutValue( 0x22 )

			print('We are in state %04x.' % state)	
			print('The RFIFO was written %04x times.' % times_RFIFO_written)
			print('We should read %04x pieces of data.' % times_to_read_RFIFO)

		while (times_to_read_RFIFO > 0):
			#Sending in access_RFIF0
			dev.SetWireInValue( 0x02, 0x0044, 0xffff )
			dev.UpdateWireIns()
	
			dev.UpdateWireOuts()
			out = dev.GetWireOutValue( 0x20 )
			print('reading out: %04x' % out)
			#finished reading segment
			if (times_to_read_RFIFO > 0):
				#not finished with RFIFO
				dev.SetWireInValue( 0x02, 0x0086, 0xffff )
				dev.UpdateWireIns()
				times_to_read_RFIFO -= 1
			else:
				#finished with RFIFO
				dev.SetWireInValue( 0x02, 0x0186, 0xffff )
				dev.UpdateWireIns()

		print("done reading continue")

		#checks on ep25, ep30
		dev.UpdateWireOuts()
		ep25value = dev.GetWireOutValue( 0x25 )
		print("\nAfter done with AT")
		print('0x25: %04x' % ep25value)

		#Not Needed Anymore
		#dev.UpdateWireOuts()
		#ep30value = dev.GetWireOutValue( 0x30 )
		#print('0x30: %04x' % ep30value)

	#no AT commands, or just reading
	elif (write == -1):
		#Start with reset
		dev.SetWireInValue( 0x02, 0x0001, 0xffff )
		dev.UpdateWireIns()

		# activatng begin_connection and activate user_data_loaded (put e for AT, 1c for no AT) (note: may be necessary if need to bypass)
		dev.SetWireInValue(0x02, 0x0004, 0xffff)
		dev.UpdateWireIns() # comment out this line when there is AT

		dev.UpdateWireOuts()
		ep25 = dev.GetWireOutValue( 0x25 )
		ep26 = dev.GetWireOutValue( 0x26 )
		ep27 = dev.GetWireOutValue( 0x27 )
		print('25 = %04x.' % ep25)
		print('26 = %04x.' % ep26)
		print('27 = %04x.' % ep27)

		'''
		#waiting on data_stream ready
		#start the code (AT) and reading
		#print "Starting Receiving from RFIFO"
	
		dev.UpdateWireOuts()
		out = 0
		state = dev.GetWireOutValue( 0x25 ) & 0x000F
		times_RFIFO_written = dev.GetWireOutValue( 0x21 )
		times_to_read_RFIFO = dev.GetWireOutValue( 0x22 )
		
		print('We are in state %x.' % state)
		print('The RFIFO was written %04x times.' % times_RFIFO_written)
		print('We should read %04x pieces of data.' % times_to_read_RFIFO)

		while (times_to_read_RFIFO > 0):
			#Sending in access_RFIF0
			dev.SetWireInValue( 0x02, 0x0044, 0xffff )
			dev.UpdateWireIns()
	
			dev.UpdateWireOuts()
			out = dev.GetWireOutValue( 0x20 )
			print('reading out: %04x' % out)
			#finished reading segment
			if (times_to_read_RFIFO > 0):
				#not finished with RFIFO
				dev.SetWireInValue( 0x02, 0x0086, 0xffff )
				dev.UpdateWireIns()
				times_to_read_RFIFO -= 1
			else:
				#finished with RFIFO
				dev.SetWireInValue( 0x02, 0x0186, 0xffff )
				dev.UpdateWireIns()

		'''
	#resetting all flags and counters
	init_flag = 0
	count = 0
	write = 0
	command = ""

#resetting begin (note using reset signal, can use begin_connection set to 0)
dev.SetWireInValue(0x02, 0x0001, 0xffff)
dev.UpdateWireIns()

dev.UpdateWireOuts()
ep25value = dev.GetWireOutValue( 0x25 )
print("\nAfter reset at the end")
print('0x25: %04x' % ep25value)
	

