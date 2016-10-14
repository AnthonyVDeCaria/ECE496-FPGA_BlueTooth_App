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
#	assign user_data_done = ep02wireIn[4];
#	assign AT_FIFO_access = ep02wireIn[5];
#	assign finished_with_AT_FIFO = ep02wireIn[6];
#	assign data_select[0] = ep02wireIn[7];
#	assign data_select[1] = ep02wireIn[8];
# ____________________

#Start with reset
dev.SetWireInValue( 0x02, 0x0001, 0xffff )
dev.UpdateWireIns()

#reading current state #
dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
print 'Before start 0x20: %04x' % ep20value

# activatng begin_connection and activate user_data_loaded
dev.SetWireInValue(0x02, 0x000e, 0xffff)

# sending in AT command 
dev.SetWireInValue( 0x01, 0x4154, 0xffff )
dev.UpdateWireIns()

#reading current state #
dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
print 'After first load data 0x20: %04x' % ep20value

dev.SetWireInValue( 0x01, 0x0d0a, 0xffff )   # number of words written to fifos
dev.UpdateWireIns()
dev.SetWireInValue( 0x02, 0x0018, 0xffff )
dev.UpdateWireIns()

#reading current state #
dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
print 'After done loading all data 0x20: %04x' % ep20value


#sending in AT_FIFO_access
dev.SetWireInValue( 0x02, 0x0020, 0xffff )
dev.UpdateWireIns()

#start the code (AT)

print "Starting ...."

#reading from ep out
#ep20 [0-3] = curr
#ep20 [4-7] = next
#tx_done
#assign ep20wireOut[9] = rx_done;
#assign ep20wireOut[11] = TFIFO_empty;
#assign ep20wireOut[12] = TFIFO_wr_en;
#assign ep20wireOut[13] = TFIFO_rd_en;
#assign ep20wireOut[14] = AT_FIFO_wr_en;
#assign ep20wireOut[15] = AT_FIFO_rd_en;

#assign ep21wireOut = AT_FIFO_in;
#assign ep22wireOut = TFIFO_out;
#assign ep24wireOut = TFIFO_rd_count;
#assign ep25wireOut = TFIFO_wr_count;
#assign ep26wireOut = AT_FIFO_rd_count;
#assign ep27wireOut = AT_FIFO_wr_count;
dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
ep21value = dev.GetWireOutValue( 0x21 )
ep22value = dev.GetWireOutValue( 0x22 )
ep23value = dev.GetWireOutValue( 0x23 ) # ep40 input
ep24value = dev.GetWireOutValue( 0x24 )
ep25value = dev.GetWireOutValue( 0x25 )
ep26value = dev.GetWireOutValue( 0x26 )
ep27value = dev.GetWireOutValue( 0x27 )
print "\nAT"
print '0x20: %04x' % ep20value
print '0x21: %04x' % ep21value
print '0x22: %04x' % ep22value
print '0x23: %04x' % ep23value
print '0x24: %04x' % ep24value
print '0x25: %04x' % ep25value
print '0x26: %04x' % ep26value
print '0x27: %04x' % ep27value

#finished with AT_FIFO

dev.SetWireInValue( 0x02, 0x0040, 0xffff )
dev.UpdateWireIns()

dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
print "\nAfter done with AT"
print '0x20: %04x' % ep20value

#resetting begin
dev.SetWireInValue(0x02, 0x0001, 0xffff)
dev.UpdateWireIns()

dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
print "\nAfter reset at the end"
print '0x20: %04x' % ep20value

