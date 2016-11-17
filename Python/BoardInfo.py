# BoardInfo.py
#
# This module contains some functions that query the device to find out the
# current PLL and output settings, and device information and print it.
#
# Before using these functions:
# import ok
# import BoardInfo as info
#
# Created by: Brendan Crowley
# Created on: Sep. 22, 2012
#
# Version 2: Jan 31, 2014
#   -improved the printout formatting

class ClkSrc:
	""" create an "enumerated" type to describe clock sources to use in
	the SetOutputSource function.  Note that you could just use the integer,
	but this is more descriptive """
	Ref = 0
	PLL0_0 = 2
	PLL0_180 = 3
	PLL1_0 = 4
	PLL1_180 = 5
	PLL2_0 = 6
	PLL2_180 = 7

class Clk:
	""" create an "enumerated" type to describe clock names to use in the
	clk output functions.  Note that you could just use the integer, but
	this is more descriptive """
	A = 0
	B = 1
	C = 2
	D = 3
	E = 4

ClkSrcDict = { 	0 : 'Ref',
				2 : 'PLL0_0',
				3 : 'PLL0_180',
				4 : 'PLL1_0',
				5 : 'PLL1_180',	
				6 : 'PLL2_0',
				7 : 'PLL2_180' }


def GetDeviceInfo(x):
	""" display device information
		x is an instance of ok.FrontPanel() """
	if x.IsOpen() == 0:
		print 'No device is open. First call dev.OpenBySerial(\'\')'
		return

	BoardModel = x.GetBoardModel()
	BoardModelString = x.GetBoardModelString(BoardModel)
	DeviceID = x.GetDeviceID()
	DeviceMajVer = x.GetDeviceMajorVersion()
	DeviceMinVer = x.GetDeviceMinorVersion()
	DeviceSerNum = x.GetSerialNumber()
	print 'Device Information:'
	print 'Board Model is %s = %s' % (BoardModel, BoardModelString)
	print 'Device ID is %s' % DeviceID
	print 'Device Version is %d.%d' % (DeviceMajVer, DeviceMinVer)
	print 'Device Serial Number is %s\n' % DeviceSerNum	


def GetPLLInfo(x):
	""" display current PLL settings
		x is an instance of ok.PLL22393() """
	print 'PLL Settings:'

	ClkRef = x.GetReference()	
	print 'Reference frequency = %f MHz' % ClkRef

	PLL1P = x.GetPLLP(0)
	PLL1Q = x.GetPLLQ(0)
	PLL1F = x.GetPLLFrequency(0)
	PLL1EN = x.IsPLLEnabled(0)

	PLL2P = x.GetPLLP(1)
	PLL2Q = x.GetPLLQ(1)
	PLL2F = x.GetPLLFrequency(1)
	PLL2EN = x.IsPLLEnabled(1)

	PLL3P = x.GetPLLP(2)
	PLL3Q = x.GetPLLQ(2)
	PLL3F = x.GetPLLFrequency(2)
	PLL3EN = x.IsPLLEnabled(2)


	print 'PLL0: P = {0:3d}, Q = {1:3d}, Freq = {2:9f} MHz, Enabled = {3:5}'.format(PLL1P,PLL1Q,PLL1F,str(PLL1EN))
	print 'PLL1: P = {0:3d}, Q = {1:3d}, Freq = {2:9f} MHz, Enabled = {3:5}'.format(PLL2P,PLL2Q,PLL2F,str(PLL2EN))
	print 'PLL2: P = {0:3d}, Q = {1:3d}, Freq = {2:9f} MHz, Enabled = {3:5}'.format(PLL3P,PLL3Q,PLL3F,str(PLL3EN))


def GetClkInfo(x):
	""" display current Clock settings
		x is an instance of ok.PLL22393() """
	print 'Clock Settings:'

	CLK1Src = ClkSrcDict[x.GetOutputSource(0)]
	CLK1Div = x.GetOutputDivider(0)
	CLK1Freq = x.GetOutputFrequency(0)
	CLK1En = x.IsOutputEnabled(0)

	CLK2Src = ClkSrcDict[x.GetOutputSource(1)]
	CLK2Div = x.GetOutputDivider(1)
	CLK2Freq = x.GetOutputFrequency(1)
	CLK2En = x.IsOutputEnabled(1)

	CLK3Src = ClkSrcDict[x.GetOutputSource(2)]
	CLK3Div = x.GetOutputDivider(2)
	CLK3Freq = x.GetOutputFrequency(2)
	CLK3En = x.IsOutputEnabled(2)

	CLK4Src = ClkSrcDict[x.GetOutputSource(3)]
	CLK4Div = x.GetOutputDivider(3)
	CLK4Freq = x.GetOutputFrequency(3)
	CLK4En = x.IsOutputEnabled(3)

	CLK5Src = ClkSrcDict[x.GetOutputSource(4)]
	CLK5Div = x.GetOutputDivider(4)
	CLK5Freq = x.GetOutputFrequency(4)
	CLK5En = x.IsOutputEnabled(4)

	print 'CLKA = CLK1: Src = {0:>8s}, Div = {1:3d}, Freq = {2:5f} MHz, Enabled = {3:6s}'.format(CLK1Src,CLK1Div,CLK1Freq,str(CLK1En))
	print 'CLKB = CLK2: Src = {0:>8s}, Div = {1:3d}, Freq = {2:5f} MHz, Enabled = {3:6s}'.format(CLK2Src,CLK2Div,CLK2Freq,str(CLK2En))
	print 'CLKC = CLK3: Src = {0:>8s}, Div = {1:3d}, Freq = {2:5f} MHz, Enabled = {3:6s}'.format(CLK3Src,CLK3Div,CLK3Freq,str(CLK3En))
	print 'CLKD = CLK4: Src = {0:>8s}, Div = {1:3d}, Freq = {2:5f} MHz, Enabled = {3:6s}'.format(CLK4Src,CLK4Div,CLK4Freq,str(CLK4En))
	print 'CLKE = CLK5: Src = {0:>8s}, Div = {1:3d}, Freq = {2:5f} MHz, Enabled = {3:6s}'.format(CLK5Src,CLK5Div,CLK5Freq,str(CLK5En))

#	print 'CLKA = CLK1: Src = ' + str(CLK1Src).ljust(8) + ', Div = ' + str(CLK1Div).rjust(3) + ', Freq = ' + str(CLK1Freq).rjust(5) + ' MHz, Enabled = ' + str(CLK1En).rjust(5)
#	print 'CLKB = CLK2: Src = ' + str(CLK2Src).ljust(8) + ', Div = ' + str(CLK2Div).rjust(3) + ', Freq = ' + str(CLK2Freq).rjust(5) + ' MHz, Enabled = ' + str(CLK2En).rjust(5)
#	print 'CLKC = CLK3: Src = ' + str(CLK3Src).ljust(8) + ', Div = ' + str(CLK3Div).rjust(3) + ', Freq = ' + str(CLK3Freq).rjust(5) + ' MHz, Enabled = ' + str(CLK3En).rjust(5)
#	print 'CLKD = CLK4: Src = ' + str(CLK4Src).ljust(8) + ', Div = ' + str(CLK4Div).rjust(3) + ', Freq = ' + str(CLK4Freq).rjust(5) + ' MHz, Enabled = ' + str(CLK4En).rjust(5)
#	print 'CLKE = CLK5: Src = ' + str(CLK5Src).ljust(8) + ', Div = ' + str(CLK5Div).rjust(3) + ', Freq = ' + str(CLK5Freq).rjust(5) + ' MHz, Enabled = ' + str(CLK5En).rjust(5) + '\n'


