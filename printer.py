'''
Thermal printer manager for thermal printer logs
'''

import glob
import sys
import logger
import global_vars as gv
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
		state = bool(_filter_port in raw_ports)

	if sys.platform.startswith('darwin'):
		state = bool(_filter_port in raw_ports)
	return state




def print_text(_filter_port, _data):
	'''Thermal printer pritning logic and utility function'''
	if have_printer_port(_filter_port):
		printer = ThermalPrinter(port=_filter_port, baudrate=19200)
		have_paper = False

		if printer.is_online is False:
			printer.online()
		if printer.is_sleeping:
			printer.wake()

		have_paper = bool(printer.status()['paper'])

		if have_paper:
			if isinstance(_data, str):
				if _data.startswith(gv.heading_identifier): # it is a heading
					# get rid of the heading identifier from teh serial string
					_data = _data.replace(gv.heading_identifier, '')
					printer.out(_data, bold=True, justify='L', left_margin=0, size='S')
				elif _data.startswith('TEST'): # it is a header or a footer
					printer.out(_data, bold=True, justify='L', left_margin=0, size='S', underline=1)
					# printer.out(_item, underline=1)
				else:
					printer.out(_data, bold=False, justify='L', left_margin=0, size='S')
			if isinstance(_data, list):
				for _item in _data:
					if _item.startswith(gv.heading_identifier): # it is a heading
						_item = _item.replace(gv.heading_identifier, '')
						printer.out(_item, bold=True, justify='L', left_margin=0, size='S')
					elif _item.startswith('TEST'): # it is a header or a footer
						printer.out(_item, bold=True, justify='L', left_margin=0, size='S', underline=1)
						# printer.out(_item, underline=1)
					else:
						printer.out(_item, bold=False, justify='L', left_margin=0, size='S')
			printer.feed(4)
		else:
			# print("No paper")
			logger.log_warning(["", "You asked a Thermal printer to print the log.",
								               "But there is no paper in the printer"
						  	             ])
			gv.output_msg_buff = ["", "Asked for physical log.", "But no paper in printer!"]
	else:
		# print("No printer")
		logger.log_warning(["", "You asked a Thermal printer to print the log.",
							               "But there is no Thermal printer on the port:",
							               gv.printer_port
						               ])
		gv.output_msg_buff = ["", "Asked for physical log.", "But no printer on the port:",
							                 gv.printer_port
							                ]


# print_text('/dev/tty.usbserial-AI05HDSG', '[H]printer is there!')
# print_text('/dev/tty.usbserial-AI05HDSG', 'TEST printer is there!')
# print_text('/dev/tty.usbserial-AI05HDSG', 'CHECKING Checking')

# import time
# while True:
# 	print_text_receipt('/dev/tty.usbserial-AI05HDSG', 'printer is there!')
# 	time.sleep(4)
