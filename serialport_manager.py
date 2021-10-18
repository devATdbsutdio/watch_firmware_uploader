'''
Module for: MANAGING SERIAL PORT REALTED FUNCTIONs (as listyed below)
1. Listing ports
2. Opening ports
3. closing ports
4. How swapping port handling
5. Reading from port (Reading data from test firmware)
6. Writing to port (for tim e setting to clock module)
7. Updating UI & logs
'''

import threading
import glob
import time
import sys
import serial
import serial.tools.list_ports

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
		logger.log_exception(err)
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
			logger.log_exception(err)
			# pass
		serclosed = not SER.isOpen()
	else:
		serclosed = True
	return serclosed


def get_ser_data_line():
	'''Serial Read line method for reading cont. Arduino's serial println()'''
	serial_available = False

	gv.test_log_dict = []

	gv.test_data_read = False
	#- log file
	logger.log_info("Serial Read thread has started!")
	# - UI
	gv.output_msg_buff = ["Serial Read thread has started!"]
	while True:
		time.sleep(.001)
		incoming_line = ""

		try:
			if SER:
				serial_available = True
			else:
				serial_available = False
				break
		except Exception as ERR:
			serial_available = False
			break


		# [TBD] check if serial is open vs exception on Hw line disconnect 
		if serial_available:
			incoming_line = SER.readline()
			while '\\n' not in str(incoming_line):
				time.sleep(.001)
				temp = SER.readline()
				
				if temp.decode():
					incoming_line = (incoming_line.decode()+temp.decode()).encode()
			incoming_line = incoming_line.decode()
			incoming_line = incoming_line.strip()

			#- Serial RXTX line check by comnfirming received flag
			if incoming_line == 'SERIAL:1':
				logger.log_info("Serial COM is okay!")
				gv.output_msg_buff = ["Serial COM is okay!"]

			#- uC dev board send "!" as a char to end the serial read
			if incoming_line == "!":
				gv.test_data_read = True
				logger.log_info("Terminator received")
				gv.output_msg_buff = ["Terminator received"]
				# current time: in log and printer
				break

			#- Add incoming lines to a buffer array dict for thermal printer
			gv.test_log_dict.append(incoming_line)

			#- Remove header marker from serial data string
			serial_log_str = incoming_line
			if serial_log_str.startswith('[H]'):
				serial_log_str = serial_log_str.replace('[H]', '')
			logger.log_info(serial_log_str)
			gv.output_msg_buff = [serial_log_str]

			# [TBD]
			# time out if incoming string is nothing..
			# Meaning serial is not working..



def write_to_port(_data):
	logger.log_info("Sending " + str(_data.encode()) + " to uC")
	gv.output_msg_buff = ["Sending " + str(_data.encode()) + " to uC"]
	SER.write(_data.encode())               



# ** no windows for now :)
def filtered_ser_ports():
	'''filtering of interested USB serial ports'''
	
	usable_ports = []

	for port_info in serial.tools.list_ports.comports():
		if port_info.serial_number != None and port_info.serial_number != gv.thermal_printer_serial_chip_id:
			# usable_ports.append([port_info.serial_number, port_info.device])
			port = str(port_info.device)
			port = port.strip()
			usable_ports.append(port)
	return usable_ports



def watch_ser_ports():
	'''Watches and handles debug ports, hotswapping and assignments'''
	ser_null_once = True
	ser_valid_once = True

	while True:
		if gv.kill_ser_port_watcher_thread:
			break

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
					logger.log_warning("Disabled debug serial port opening scope")
					# - UI
					gv.output_msg_buff = ["Disabled debug serial port opening scope"]
		else:
			if ser_valid_once:
				ser_valid_once = False
				ser_null_once = True
				gv.curr_serial_debug_port = gv.last_serial_debug_port
				#- log file
				logger.log_info("Chosen Debug Serial port will be available for usage")
				#- UI
				gv.output_msg_buff = ["Chosen Debug Serial port will be available for usage"]

		# Set the actual serial debug port to that current selected port
		if SER.port != gv.curr_serial_debug_port:
			SER.port = gv.curr_serial_debug_port

		# on launch only once for assigning the current serial port info
		if gv.app_launched:
			for port_info in serial.tools.list_ports.comports():
				port = str(port_info.device)
				port = port.strip()

				# if not none and not UPDI FTDI ID, must be debug chip port
				if port_info.serial_number != None and port_info.serial_number != gv.updi_ftdi_id:
					gv.curr_serial_debug_port = port
				if port_info.serial_number != None and port_info.serial_number == gv.updi_ftdi_id:
					gv.updi_port = port


			gv.last_serial_debug_port = gv.curr_serial_debug_port
			# Set the actual serial debug port to that current selected port
			SER.port = gv.curr_serial_debug_port
			# update the upload command with the *correct fixed updi port
			gv.upload_cmd[7] = gv.updi_port

			logger.log_info("UPDI: " + gv.updi_port)
			logger.log_info("SER: " + gv.curr_serial_debug_port)

			gv.app_launched = False


DEBUG_SER_PORTS_WATCHER = threading.Thread(target=watch_ser_ports)
DEBUG_SER_PORTS_WATCHER.start()
