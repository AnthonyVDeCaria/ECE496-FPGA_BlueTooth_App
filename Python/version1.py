#all this code should be the same 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
import ok
import BoardInfo as info
import struct
import matplotlib.pyplot as plt

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
x = dev.ConfigureFPGA('../FPGA_connection.bit')

#==================== Start Operations ======================
# reset system
# resetn [0]
# want_at [1]
# user_ready [2]
# data_select[0] [3]
# data_select[1] [4]
dev.ActivateTriggerIn( 0x40, 0 )

# set design parameter values

# this code necessary for wires
 dev.SetWireInValue( 0x01, 65535, 0xffff )   # number of words written to fifos
 dev.UpdateWireIns()

#reading from ep20 and ep21
ep20value = dev.GetWireOutValue( 0x20 )
ep21value = dev.GetWireOutValue( 0x21 )
print '0x20: %04x' % ep20value
print '0x21: %04x' % ep21value




