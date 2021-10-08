"""
Module for: MANAGING SERIAL PORT REALTED FUNCTIONs (as listyed below)
1. Listing ports
2. Opening ports
3. closing ports
4. How swapping port handling
5. Reading from port (Reading data from test firmware)
6. Writing to port (for tim e setting to clock module)
7. Updating UI & logs
"""

import threading
import glob
import time
import sys
import serial

import vars
import logger


# -- Serial object init
SER = serial.Serial()
SER.baudrate = 115200
SER.timeout = 0 # non-block reading
SER.bytesize = serial.EIGHTBITS
SER.parity = serial.PARITY_NONE
SER.stopbits = serial.STOPBITS_ONE
SER.port = ""


def open_serial_port(_ser_port):
	'''Valid Serial port opening method'''
	portopen = False
	SER.port = _ser_port
	try:
		SER.open()
		SER.flushInput()
		SER.flushOutput()
	except Exception as err:
		logger.log(err)
		# pass

	portopen = SER.isOpen()
	return portopen



def close_serial_port():
	'''Clean Serial port closing method'''
	serclosed = False
	if SER.isOpen():
		try:
			SER.flushInput()
			SER.flushOutput()
			SER.close()
		except Exception as err:
			logger.log(err)
			# pass
		serclosed = not SER.isOpen()
	else:
		serclosed = True
	return serclosed


def get_ser_data_line():
	'''Serial Read line method for reading cont. Arduino's serial println()'''
	vars.test_data_read = False
	#- log file
	logger.log(" Serial Read thread has started!")
	# - UI
	vars.output_msg_buff = ["Serial Read thread has started!"]
	while True:
		time.sleep(.001)
		incoming_line = SER.readline()
		# while not '\\n'in str(incoming_line):
		while '\\n' not in str(incoming_line):
			time.sleep(.001)
			temp = SER.readline()
			# if not not temp.decode():
			if temp.decode():
				incoming_line = (incoming_line.decode()+temp.decode()).encode()
		incoming_line = incoming_line.decode()
		incoming_line = incoming_line.strip()
		# uC dev board send "!" as a char to end the serial read
		if incoming_line == "!":
			vars.test_data_read = True
			break
		#- log file
		logger.log(incoming_line)
		# - UI
		vars.output_msg_buff = [incoming_line]

		# [TBD]
		# time out if incoming string is nothing..
		# Meaning serial is not working..



# create list of ports according to OS
# ** no windows for now :)
def all_ser_ports():
	'''OS based listing of all serial ports'''
	ports = []
	if sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
		ports = glob.glob('/dev/tty[A-Za-z]*')
	elif sys.platform.startswith('darwin'):
		ports = glob.glob('/dev/tty.*')
	else:
		ports = ['0', '0', '0']
	return ports


# ** no windows for now :)
def filtered_ser_ports():
	'''OS based filtering of interested USB serial ports'''
	raw_ports = all_ser_ports()
	usable_ports = []

	if sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
		for port in raw_ports:
			if port.startswith("/dev/ttyUSB"):
				usable_ports.append(port)
	elif sys.platform.startswith('darwin'):
		for port in raw_ports:
			if port.startswith("/dev/tty.usb"):
				usable_ports.append(port)
	return usable_ports



CHECK_SER_NULL_ONCE = True
CHECK_SER_VALID_ONCE = True

def watch_ser_ports():
	'''Watches and handles debug ports, hotswapping and assignments'''
	global CHECK_SER_NULL_ONCE
	global CHECK_SER_VALID_ONCE
	while True:
		# vars.kill_ser_port_watcher_thread
		# vars.serial_debug_ports
		if not vars.kill_ser_port_watcher_thread:
			vars.serial_debug_ports = filtered_ser_ports()
			# sanity checks...
			# This is to not open serial port if the port is unavailable
			if len(vars.serial_debug_ports) < 2:
				vars.serial_debug_ports.append("Null")
				vars.curr_serial_debug_port = "Null"

				# close debug serial port if was open
				if CHECK_SER_NULL_ONCE:
					if close_serial_port():
						CHECK_SER_NULL_ONCE = False
						CHECK_SER_VALID_ONCE = True
						#- log file
						logger.log(" Disabled debug serial port opening scope")
						# - UI
						vars.output_msg_buff = ["Disabled debug serial port opening scope"]
			else:
				if CHECK_SER_VALID_ONCE:
					CHECK_SER_VALID_ONCE = False
					CHECK_SER_NULL_ONCE = True
					vars.curr_serial_debug_port = vars.last_serial_debug_port
					#- log file
					logger.log(" Chosen Debug Serial port will be available for usage")
					#- UI
					vars.output_msg_buff = ["Chosen Debug Serial port will be available for usage"]

			# Set the actual serial debug port to that current selected port
			if SER.port != vars.curr_serial_debug_port:
				SER.port = vars.curr_serial_debug_port

			# on launch only once for assigning the current serial port info
			if vars.app_launched:
				vars.updi_port = vars.serial_debug_ports[0]
				vars.curr_serial_debug_port = vars.serial_debug_ports[1]
				vars.last_serial_debug_port = vars.curr_serial_debug_port
				# Set the actual serial debug port to that current selected port
				SER.port = vars.curr_serial_debug_port
				# update the upload command with the *correct fixed updi port
				vars.upload_cmd[7] = vars.updi_port
				vars.app_launched = False
		else:
			break



DEBUG_SER_PORTS_WATCHER = threading.Thread(target=watch_ser_ports)
DEBUG_SER_PORTS_WATCHER.start()
