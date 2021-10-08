import serial
import threading
import sys
import glob
import vars
import logger
import time

# -- Serial object init
ser = serial.Serial()
ser.baudrate = 115200
ser.timeout = 0 # non-block reading
ser.bytesize = serial.EIGHTBITS
ser.parity = serial.PARITY_NONE
ser.stopbits = serial.STOPBITS_ONE
ser.port = ""

def open_serial_port(_ser_port):
	portopen = False
	ser.port = _ser_port
	try:
		ser.open()
		ser.flushInput()
		ser.flushOutput()
	except Exception as e:
		logger.log(e)
		pass
	if ser.isOpen():
		portopen = True
	else:
		portopen = False
	return portopen



def close_serial_port():
	serclosed = False
	if ser.isOpen():
		try:
			ser.flushInput()
			ser.flushOutput()
			ser.close()
		except Exception as e:
			logger.log(e)
			pass
		if ser.isOpen() == False:
			serclosed = True
		else:
			serclosed = False
	else:
		serclosed = True
	return serclosed
		


def get_ser_data_line():
	vars.test_data_read = False
	#- log file 
	logger.log(" Serial Read thread has started!")
	# - UI
	vars.output_msg_buff = ["Serial Read thread has started!"]
	while True:
		time.sleep(.001)
		incoming_line = ser.readline()
		while not '\\n'in str(incoming_line):
			time.sleep(.001)
			temp = ser.readline()
			if not not temp.decode():
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


'''
-- get list of Serial ports --
'''

# kill_ser_port_watcher_thread = False
# serial_debug_ports = ['', '']

# create list of ports according to OS
# ** no windows for now :)
def all_ser_ports():
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
	raw_ports = all_ser_ports()
	usable_ports =[]

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
	while True:
		vars.kill_ser_port_watcher_thread
		vars.serial_debug_ports
		if not vars.kill_ser_port_watcher_thread:
			vars.serial_debug_ports = filtered_ser_ports() 
			
			# sanity checks...
			# This will be used, to not open serial port if the port is unavailable
			if len(vars.serial_debug_ports) < 2:
				vars.serial_debug_ports.append("Null")
				vars.curr_serial_debug_port = "Null"
			else:
				vars.curr_serial_debug_port = vars.last_serial_debug_port

			# Set the actual serial debug port to that current selected port
			if ser.port != vars.curr_serial_debug_port:
				ser.port = vars.curr_serial_debug_port
			
			# on launch only once for assigning the current serial port info
			if vars.app_launched:
				vars.updi_port = vars.serial_debug_ports[0]
				vars.curr_serial_debug_port = vars.serial_debug_ports[1]
				vars.last_serial_debug_port = vars.curr_serial_debug_port
				# Set the actual serial debug port to that current selected port
				ser.port = vars.curr_serial_debug_port
				# update the upload command with the *correct fixed updi port 
				vars.upload_cmd[7] = vars.updi_port
				vars.app_launched = False
		else:
			break



ser_port_list_watcher = threading.Thread(target=watch_ser_ports)
ser_port_list_watcher.start()








