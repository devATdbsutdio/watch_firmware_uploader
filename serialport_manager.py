
import threading
import sys
import glob
import vars

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


# filtered_ser_ports()

# import time

# while True:
# 	print(list(filtered_ser_ports()))
# 	time.sleep(1)

# for port in ports:
# 	print(port)
# 	# if port.startswith("/dev/tty"):



def watch_ser_ports():
	while True:
		vars.kill_ser_port_watcher_thread
		vars.serial_debug_ports
		if not vars.kill_ser_port_watcher_thread:
			vars.serial_debug_ports = filtered_ser_ports()
			
			# on launch only once for assigning the current serial port info
			if vars.app_launched:
				vars.updi_port = vars.serial_debug_ports[0]
				vars.curr_serial_debug_port = vars.serial_debug_ports[1]
				# update the upload command with the *correct fixed updi port 
				vars.upload_cmd[7] = vars.updi_port
				vars.app_launched = False
		else:
			break



ser_port_list_watcher = threading.Thread(target=watch_ser_ports)
ser_port_list_watcher.start()


# updi_port = '/dev/tty/USB0'

# serial_debug_port = serial_debqug_ports[0]

# ui_highlight_ser_port_0 = "> "
# ui_highlight_ser_port_1 = "  "
# ui_highlight_ser_port_2 = "  "