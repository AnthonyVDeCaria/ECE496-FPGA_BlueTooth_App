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
print 'Setting clocks...'
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
print "Configuring FPGA..."

#note change to necessary file path later
x = dev.ConfigureFPGA('/media/ming/D/ECE496/Python/FBC_w_OK.bit')

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
print 'Before start 0x21: %04x' % ep21value

# activatng begin_connection and activate user_data_loaded (put e for AT, 1c for no AT)
dev.SetWireInValue(0x02, 0x001c, 0xffff)
dev.UpdateWireIns() # comment out this line when there is AT
'''
# sending in AT command 
dev.SetWireInValue( 0x01, 0x4154, 0xffff )
dev.UpdateWireIns()

#user_knows_stored
dev.SetWireInValue(0x02, 0x0010, 0xffff)
dev.UpdateWireIns()

# more of AT command
dev.SetWireInValue(0x02, 0x000a, 0xffff)

# sending in AT command 
dev.SetWireInValue( 0x01, 0x2b4f, 0xffff )
dev.UpdateWireIns()

#user_knows_stored
dev.SetWireInValue(0x02, 0x0010, 0xffff)
dev.UpdateWireIns()

# more of AT command
dev.SetWireInValue(0x02, 0x000a, 0xffff)

# sending in AT command 
dev.SetWireInValue( 0x01, 0x5247, 0xffff )
dev.UpdateWireIns()

#user_knows_stored
dev.SetWireInValue(0x02, 0x0010, 0xffff)
dev.UpdateWireIns()

# more of AT command
dev.SetWireInValue(0x02, 0x000a, 0xffff)

# sending in AT command 
dev.SetWireInValue( 0x01, 0x4c, 0xffff )
dev.UpdateWireIns()

#user_knows_stored
dev.SetWireInValue(0x02, 0x0010, 0xffff)
dev.UpdateWireIns()

#/r/n
dev.SetWireInValue( 0x01, 0x0d0a, 0xffff )   # number of words written to fifos
dev.SetWireInValue( 0x02, 0x003e, 0xffff )   # finished here
dev.UpdateWireIns()
'''

#reading current state #
dev.UpdateWireOuts()
ep21value = dev.GetWireOutValue( 0x21 )
print 'After done loading all data 0x21: %04x' % ep21value

#sending in AT_FIFO_access
dev.SetWireInValue( 0x02, 0x0044, 0xffff )
dev.UpdateWireIns()

#start the code (AT) and reading

print "Starting ...."

#printing values of all values
dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
ep21value = dev.GetWireOutValue( 0x21 ) #states
ep22value = dev.GetWireOutValue( 0x22 )
ep23value = dev.GetWireOutValue( 0x23 ) #ep40 input
ep24value = dev.GetWireOutValue( 0x24 )
ep25value = dev.GetWireOutValue( 0x25 )
ep26value = dev.GetWireOutValue( 0x26 )
ep27value = dev.GetWireOutValue( 0x27 )
ep30value = dev.GetWireOutValue( 0x30 )

print "\nAT"
print '0x20: %04x' % ep20value
print '0x21: %04x' % ep21value
print '0x22: %04x' % ep22value
print '0x23: %04x' % ep23value
print '0x24: %04x' % ep24value
print '0x25: %04x' % ep25value
print '0x26: %04x' % ep26value
print '0x27: %04x' % ep27value
print '0x30: %04x' % ep30value
#update user_received_data
dev.SetWireInValue( 0x02, 0x0084, 0xffff )
dev.UpdateWireIns()

'''
# Testing data from wire outs
epbuf = bytearray(256)  # buffer to store the BTpipeOut data
i = 0;
while (i < 256):
	dev.UpdateWireOuts()
	ep21value = dev.GetWireOutValue( 0x21 )
	ep21value = ep21value >> 14
	ep21value = ep21value & 1
	epbuf[i] = ep21value
	i = i + 1

plt.figure(1)
plt.plot(epbuf)
plt.ylabel('ep')
plt.xlabel('sample')
plt.title('streaming: ep')
'''

#ep20 for reading values out
out = 1
while (out != 0): 
	#forward
	dev.SetWireInValue( 0x02, 0x0044, 0xffff )
	dev.UpdateWireIns()
	
	dev.UpdateWireOuts()
	out = dev.GetWireOutValue( 0x20 )
	print 'reading out: %04x' % out
	#finished reading segment
	dev.SetWireInValue( 0x02, 0x0084, 0xffff )
	dev.UpdateWireIns()


print "done reading continue"

#finished with AT_FIFO
dev.SetWireInValue( 0x02, 0x0104, 0xffff )
dev.UpdateWireIns()

dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x21 )
print "\nAfter done with AT"
print '0x21: %04x' % ep20value


#plt.show()
curr = 0
while (curr != 0xff):
	dev.UpdateWireOuts()
	ep20value = dev.GetWireOutValue( 0x21 )
	curr = ep21value & 0xff
	print '0x21: %04x' % curr

print 'success'

dev.UpdateWireOuts()
ep30value = dev.GetWireOutValue( 0x30 )
print '0x30: %04x' % ep30value
print "\nAfter reset at the end"
#temporary, just to ensure it reachs and stays at 0xff delete later!!!
while (1):
	a = 0

#resetting begin (note using reset signal, can use begin_connection set to 0)
dev.SetWireInValue(0x02, 0x0001, 0xffff)
dev.UpdateWireIns()

dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x21 )
print "\nAfter reset at the end"
print '0x21: %04x' % ep20value

