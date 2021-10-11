'''
Thermal printer manager for thermal printer logs
'''

import glob
import sys
from thermalprinter import ThermalPrinter


def all_ser_ports():
	'''OS based listing of all serial ports'''
	ports = []
	if sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
		ports = glob.glob('/dev/tty[A-Za-z]*')
	if sys.platform.startswith('darwin'):
		ports = glob.glob('/dev/tty.*')
	return ports


def have_printer_port(_filter_port):
	''' OS based filetring of tehrmal printer port'''
	raw_ports = all_ser_ports()
	state = False

	if sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
		if _filter_port in raw_ports:
			state = True
		else:
			state = False
	if sys.platform.startswith('darwin'):
		if _filter_port in raw_ports:
			state = True
		else:
			state = False
	return state




def print_text(_filter_port, _data):
	global PAPER_WIDTH

	if have_printer_port(_filter_port):
		printer = ThermalPrinter(port=_filter_port, baudrate = 19200)
		have_paper = False


		if printer.is_online is False:
			printer.online()
		if printer.is_sleeping:
			printer.wake()

		if printer.status()['paper']:
			have_paper = True
		else:
			have_paper = False

		if isinstance(_data, str):
			# TBD: Assign the heading identifier from global_vars.py 
			if _data.startswith('[H]'): # it is a heading
				_data = _data.replace('[H]', '')
				printer.out(_data, bold=True, justify='L',left_margin=0, size='S')
			else:
				printer.out(_data, bold=False, justify='L',left_margin=0, size='S')
		if isinstance(_data, list):
			for _item in _data:
				if _item.startswith('[H]'): # it is a heading
					_item = _item.replace('[H]', '')
					printer.out(_item, bold=True, justify='L', left_margin=0, size='S')
				else:
					printer.out(_item, bold=False, justify='L',left_margin=0, size='S')

		printer.feed(2)





# print_text_receipt('/dev/tty.usbserial-AI05HDSG', '[H]printer is there!')
# print_text_receipt('/dev/tty.usbserial-AI05HDSG', 'printer is there!')

# import time
# while True:
# 	print_text_receipt('/dev/tty.usbserial-AI05HDSG', 'printer is there!')
# 	time.sleep(4)
