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
x = dev.ConfigureFPGA('/media/ming/D/ECE496/Python/fbc_w_ok.bit')

#==================== Start Operations ======================
# reset system
# resetn [0] 0 to reset
# want_at [1] 1 to send
# user_ready [2] 1 to ready
# data_select[0] [3] 
# data_select[1] [4]
dev.ActivateTriggerIn( 0x40, 0 )

# this code necessary for wires
dev.SetWireInValue( 0x01, 0x41540d0a, 0xffffffff )   # number of words written to fifos
dev.UpdateWireIns()

#start the code
dev.ActivateTriggerIn( 0x40, 0 )

dev.ActivateTriggerIn( 0x40, 7 )

print "Starting ...."

#reading from ep20 and ep21
dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
ep21value = dev.GetWireOutValue( 0x21 )
ep22value = dev.GetWireOutValue( 0x22 )
print "\nAT"
print '0x20: %04x' % ep20value
print '0x21: %04x' % ep21value
print '0x22: %04x' % ep22value

# trying AT+RESET
dev.SetWireInValue( 0x01, 0x41542b52, 0xffffffff )   # number of words written to fifos
dev.UpdateWireIns()
dev.SetWireInValue( 0x01, 0x45534554, 0xffffffff )   # number of words written to fifos
dev.UpdateWireIns()
dev.SetWireInValue( 0x01, 0x0d0a, 0xffff )   # number of words written to fifos
dev.UpdateWireIns()

dev.ActivateTriggerIn( 0x40, 0 )

dev.ActivateTriggerIn( 0x40, 7 )

#reading from ep20 and ep21
dev.UpdateWireOuts()
ep20value = dev.GetWireOutValue( 0x20 )
ep21value = dev.GetWireOutValue( 0x21 )
ep22value = dev.GetWireOutValue( 0x22 )
print "\nAT+RESET"
print '0x20: %04x' % ep20value
print '0x21: %04x' % ep21value
print '0x22: %04x' % ep22value

# trying AT+VERSION?
dev.SetWireInValue( 0x01, 0x41542b56, 0xffffffff )   # number of words written to fifos
dev.UpdateWireIns()
dev.SetWireInValue( 0x01, 0x45525349, 0xffffffff )   # number of words written to fifos
dev.UpdateWireIns()
dev.SetWireInValue( 0x01, 0x4f4e3f0d, 0xffffffff )   # number of words written to fifos
dev.UpdateWireIns()
dev.SetWireInValue( 0x01, 0x0a, 0xff )   # number of words written to fifos
dev.UpdateWireIns()

dev.ActivateTriggerIn( 0x40, 0 )

dev.ActivateTriggerIn( 0x40, 7 ) 

#reading from ep20 and ep21
dev.UpdateWireOuts()
e20value = dev.GetWireOutValue( 0x20 )
ep21value = dev.GetWireOutValue( 0x21 )
ep22value = dev.GetWireOutValue( 0x22 )
print "\nAT+VERSION?"
print '0x20: %04x' % ep20value
print '0x21: %04x' % ep21value
print '0x22: %04x' % ep22value


