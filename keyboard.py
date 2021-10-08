#!/usr/bin/env python

import threading
import vars
import executer as action
import logger
import serialport_manager as spm
import time

# spl_key = False


import sys
import tty
import termios

EOC = '\x03'  # CTRL+C
EOT = '\x04'  # CTRL+D
ESC = '\x1b'
CSI = '['

string = ''

def getchar():
	fd = sys.stdin.fileno()
	attr = termios.tcgetattr(fd)
	try:
		tty.setraw(fd)
		return sys.stdin.read(1)
	finally:
		termios.tcsetattr(fd, termios.TCSANOW, attr)


def watch_kbd():
	string=''

	while True:
		c = getchar()

		if c == EOT or c == EOC or c == ESC:
			break
		elif c == '\r':
			# print(string)
			if string == '0' and not vars.port_selection_active:
				# Assign test code as the firmware to be uploaded
				vars.curr_firmware_num = 0
				vars.curr_firmware_name = vars.test_firmware_name
				vars.curr_firmware_path = vars.test_firmware_path
				# Update the visual highlither variable for UI
				vars.ui_highlight_test_firmware = "> "
				vars.ui_highlight_prod_firmware = "  "
				# update the upload code command
				vars.upload_cmd[4] = vars.curr_firmware_path
				logger.log(' '.join(vars.upload_cmd))
			elif string == '0' and vars.port_selection_active:
				# Assign current debug port as the current port
				vars.curr_serial_debug_port = vars.serial_debug_ports[0]
				vars.last_serial_debug_port = vars.curr_serial_debug_port
				# Update the visual highlither variable for UI
				vars.ui_highlight_ser_port_0 = "> "
				vars.ui_highlight_ser_port_1 = "  "
			if string == '1' and not vars.port_selection_active:
				# Assign production code as the firmware to be uploaded
				vars.curr_firmware_num = 1
				vars.curr_firmware_name = vars.prod_firmware_name
				vars.curr_firmware_path = vars.prod_firmware_path
				# update the visual highlither variable for UI
				vars.ui_highlight_test_firmware = "  "
				vars.ui_highlight_prod_firmware = "> "
				# update the upload code command
				vars.upload_cmd[4] = vars.curr_firmware_path
				logger.log(' '.join(vars.upload_cmd))
			elif string == '1' and vars.port_selection_active:
				# Assign current debug port as the current port
				vars.curr_serial_debug_port = vars.serial_debug_ports[1]
				vars.last_serial_debug_port = vars.curr_serial_debug_port
				# update the visual highlither variable for UI
				vars.ui_highlight_ser_port_0 = "  "
				vars.ui_highlight_ser_port_1 = "> "
			
			if string == 's':
				vars.port_selection_active = not vars.port_selection_active
			elif string == 'p':
				#--- Pull latest firmware ---#
				# action.execute(["cmd_arg", "cmd_arg", ...], <timeout_value_in_sec>)
				action.execute(vars.git_pull_cmd, 120)

				# TBD: write curr time in pullrequest_log
			elif string == 'u':
				#--- Upload current firmware (which ever it is (prod or test))
				#  In UI, show that the "upload firmware" cmd will be executed
				vars.output_msg_buff = ["Uploading current firmware: "+ vars.curr_firmware_name]					
				action.execute(vars.upload_cmd, 220)

				time.sleep(2)

				#--- Open DEBUG serial port if it is not opened,
				if vars.curr_serial_debug_port != "Null" and \
					vars.curr_serial_debug_port != vars.updi_port and \
					vars.debug_channel_open == False:

					# Open DEBUG serial port if it is not opened
					vars.debug_channel_open = spm.open_serial_port(vars.curr_serial_debug_port)

					if vars.debug_channel_open:
						logger.log(" Serial Port is now open")
						vars.output_msg_buff = ["Serial Port is now open"]
						vars.debug_port_status = "Open"
					else:
						vars.debug_port_status = "Closed"
						logger.log(" Error Opening the Debug Serial Port!")
						vars.output_msg_buff = ["Error Opening the Debug Serial Port!"]

				#--- Serial read write based on current firmware
				if vars.curr_firmware_num == 0:
					if vars.debug_channel_open:
						# Read serial monitor and print in receipts
						logger.log(" Reading serial data")
						vars.output_msg_buff = ["Serial Read thread has started!"]
						spm.get_ser_data_line()
					else:
						#- log file 
						logger.log([
							" Debug Serial Port could not be opened", 
							" So not starting Serial Read!"
						])
						#- UI
						vars.output_msg_buff = [
							"Debug Serial Port could not be opened", 
							"So not starting Serial Read!"
						]

				if vars.curr_firmware_num == 1:
					# TBD: Write curr Time Data when uC is awake:
					if vars.debug_channel_open:
						ct=1
					else:
						ct=0

				#--- Close DEBUG serial port if it is opened
				if spm.close_serial_port():
					vars.debug_channel_open = False
					vars.debug_port_status = "Closed"
					logger.log(" Serial Port Closed")
				else:
					vars.debug_channel_open = True
					vars.debug_port_status = "Open"
					logger.log(" Serial Port Error Closing")


			if string == '1' and vars.test_data_read:
				# [TBD]
				# Meaning data was read sucessfully and 
				# user pressed 1, so display is working!
				# show that in receipt printer
				vars.test_data_read = False
			if string == '0' and vars.test_data_read:
				# [TBD]
				# Meaning data was NOT read and 
				# user pressed 0, so display is NOT working!
				# show that in receipt printer
				vars.test_data_read = False

			string = ''
		else:
			string += c


kbd_thread = threading.Thread(target=watch_kbd)
kbd_thread.start()