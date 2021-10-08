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

import global_vars as gv
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
	# except Exception as err:
	except serial.SerialException as err:
		logger.log(err)
	except TypeError as err:
		SER.flushInput()
		SER.flushOutput()
		SER.close()

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
		# except Exception as err:
		except serial.SerialException as err:
			logger.log(err)
			# pass
		serclosed = not SER.isOpen()
	else:
		serclosed = True
	return serclosed


def get_ser_data_line():
	'''Serial Read line method for reading cont. Arduino's serial println()'''
	gv.test_data_read = False
	#- log file
	logger.log(" Serial Read thread has started!")
	# - UI
	gv.output_msg_buff = ["Serial Read thread has started!"]
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
			gv.test_data_read = True
			break
		#- log file
		logger.log(incoming_line)
		# - UI
		gv.output_msg_buff = [incoming_line]

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





def watch_ser_ports():
	'''Watches and handles debug ports, hotswapping and assignments'''
	ser_null_once = True
	ser_valid_once = True

	while True:
		if not gv.kill_ser_port_watcher_thread:
			gv.serial_debug_ports = filtered_ser_ports()

			# sanity checks...
			# This is to not open serial port if the port is unavailable
			if len(gv.serial_debug_ports) < 2:
				gv.serial_debug_ports.append("Null")
				gv.curr_serial_debug_port = "Null"

				# close debug serial port if was open
				if ser_null_once:
					if close_serial_port():
						ser_null_once = False
						ser_valid_once = True
						#- log file
						logger.log(" Disabled debug serial port opening scope")
						# - UI
						gv.output_msg_buff = ["Disabled debug serial port opening scope"]
			else:
				if ser_valid_once:
					ser_valid_once = False
					ser_null_once = True
					gv.curr_serial_debug_port = gv.last_serial_debug_port
					#- log file
					logger.log(" Chosen Debug Serial port will be available for usage")
					#- UI
					gv.output_msg_buff = ["Chosen Debug Serial port will be available for usage"]

			# Set the actual serial debug port to that current selected port
			if SER.port != gv.curr_serial_debug_port:
				SER.port = gv.curr_serial_debug_port

			# on launch only once for assigning the current serial port info
			if gv.app_launched:
				gv.updi_port = gv.serial_debug_ports[0]
				gv.curr_serial_debug_port = gv.serial_debug_ports[1]
				gv.last_serial_debug_port = gv.curr_serial_debug_port
				# Set the actual serial debug port to that current selected port
				SER.port = gv.curr_serial_debug_port
				# update the upload command with the *correct fixed updi port
				gv.upload_cmd[7] = gv.updi_port
				gv.app_launched = False
		else:
			break



DEBUG_SER_PORTS_WATCHER = threading.Thread(target=watch_ser_ports)
DEBUG_SER_PORTS_WATCHER.start()
