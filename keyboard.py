'''
key press based event handler (for business logic of operations in the modules)
'''

import time
import sys
import tty
import termios


import threading
import global_vars as gv
import executer as action
import logger
import serialport_manager as spm
import get_date_time as sys_clock


# spl_key = False


EOC = '\x03'  # CTRL+C
EOT = '\x04'  # CTRL+D
ESC = '\x1b'
CSI = '['

# string = ''

def getchar():
	'''gettingkey press characters OS irrespective'''
	fdd = sys.stdin.fileno()
	attr = termios.tcgetattr(fdd)
	try:
		tty.setraw(fdd)
		return sys.stdin.read(1)
	finally:
		termios.tcsetattr(fdd, termios.TCSANOW, attr)


def watch_kbd():
	'''key press -> to business logic'''
	string = ''

	while True:
		char = getchar()

		if char == EOT or char == EOC or char == ESC:
			break
		elif char == '\r':
			# print(string)
			if string == '0' and not gv.port_selection_active:
				# Assign test code as the firmware to be uploaded
				gv.curr_firmware_num = 0
				gv.curr_firmware_name = gv.test_firmware_name
				gv.curr_firmware_path = gv.test_firmware_path
				# Update the visual highlither variable for UI
				gv.ui_highlight_test_firmware = "> "
				gv.ui_highlight_prod_firmware = "  "
				# update the upload code command
				gv.upload_cmd[4] = gv.curr_firmware_path
				logger.log_info(' '.join(gv.upload_cmd))
			elif string == '0' and gv.port_selection_active:
				# Assign current debug port as the current port
				gv.curr_serial_debug_port = gv.serial_debug_ports[0]
				gv.last_serial_debug_port = gv.curr_serial_debug_port
				# Update the visual highlither variable for UI
				gv.ui_highlight_ser_port_0 = "> "
				gv.ui_highlight_ser_port_1 = "  "
			if string == '1' and not gv.port_selection_active:
				# Assign production code as the firmware to be uploaded
				gv.curr_firmware_num = 1
				gv.curr_firmware_name = gv.prod_firmware_name
				gv.curr_firmware_path = gv.prod_firmware_path
				# update the visual highlither variable for UI
				gv.ui_highlight_test_firmware = "  "
				gv.ui_highlight_prod_firmware = "> "
				# update the upload code command
				gv.upload_cmd[4] = gv.curr_firmware_path
				logger.log_info(' '.join(gv.upload_cmd))
			elif string == '1' and gv.port_selection_active:
				# Assign current debug port as the current port
				gv.curr_serial_debug_port = gv.serial_debug_ports[1]
				gv.last_serial_debug_port = gv.curr_serial_debug_port
				# update the visual highlither variable for UI
				gv.ui_highlight_ser_port_0 = "  "
				gv.ui_highlight_ser_port_1 = "> "

			if string == 's':
				gv.port_selection_active = not gv.port_selection_active
			elif string == 'p':
				#--- Pull latest firmware ---#
				# action.execute(["cmd_arg", "cmd_arg", ...], <timeout_value_in_sec>)
				action.execute(gv.git_pull_cmd, 120)
			elif string == 'u':
				#--- Upload current firmware (which ever it is (prod or test))
				#  In UI, show that the "upload firmware" cmd will be executed
				gv.output_msg_buff = ["Uploading current firmware: "+ gv.curr_firmware_name]
				action.execute(gv.upload_cmd, 220)

				time.sleep(2)

				#--- Open DEBUG serial port if it is not opened,
				if gv.curr_serial_debug_port != "Null" and \
					gv.curr_serial_debug_port != gv.updi_port and \
					gv.debug_channel_open == False:

					# Open DEBUG serial port if it is not opened
					gv.debug_channel_open = spm.open_serial_port(gv.curr_serial_debug_port)

					if gv.debug_channel_open:
						logger.log_info("Serial Port is now open")
						gv.output_msg_buff = ["Serial Port is now open"]
						gv.debug_port_status = "Open"
					else:
						gv.debug_port_status = "Closed"
						logger.log_error(" Error Opening the Debug Serial Port!")
						gv.output_msg_buff = ["Error Opening the Debug Serial Port!"]
				else:
					gv.output_msg_buff = ["Debug Port is same as UPDI port", "Change it!"]
					logger.log_error(["Debug Port is same as UPDI port", "Change it!"])


				#--- Serial read/write based on current firmware 0/1
				if gv.curr_firmware_num == 0:
					if gv.debug_channel_open:
						# Read serial monitor and print in receipts
						logger.log_info("Reading serial data")
						gv.output_msg_buff = ["Serial Read thread has started!"]
						spm.get_ser_data_line()
					else:
						#- log file
						logger.log_error(["Debug Serial Port could not be opened",
							                 "So not starting Serial Read!"])
						#- UI
						gv.output_msg_buff = ["Debug Serial Port could not be opened",
						                      "So not starting Serial Read!"
						                     ]

				if gv.curr_firmware_num == 1:
					# Send time data for RTC in uC to reset time according 
					# to computer's true time. So, @ some frequency, for 
					# some seconds, send the date and time in correct format
					# to the uC.
					if gv.debug_channel_open:
						logger.log_info("\nWill Start sending time data for RTC's time RESET")
						gv.output_msg_buff = ["Will Start sending time data bursts over Serial",
						                      "For the watch to use it for setting proper time.",
						                      "Press the \"button\" on the watch for it to work"]
						time.sleep(3)

						sending_process_counter = 0
						while sending_process_counter < 20:
							# TBD: get date time
							spm.write_to_port(sys_clock.get_formatted_time())
							sending_process_counter += 1
							time.sleep(1)


				#--- Close DEBUG serial port if it is opened
				if spm.close_serial_port():
					gv.debug_channel_open = False
					gv.debug_port_status = "Closed"
					logger.log_info("Serial Port Closed")
					gv.output_msg_buff = ["Serial Port Closed"]

					time.sleep(1)
					if gv.curr_firmware_num == 1:
						gv.output_msg_buff = ["", "Hopefully correct time is set on watch!", ""]
				else:
					gv.debug_channel_open = True
					gv.debug_port_status = "Open"
					logger.log_error("Serial Port Error Closing")
					gv.output_msg_buff = ["Serial Port Closed"]


			if string == '1' and gv.test_data_read:
				# [TBD]
				# Meaning data was read sucessfully and
				# user pressed 1, so display is working!
				# show that in receipt printer
				gv.test_data_read = False
			if string == '0' and gv.test_data_read:
				# [TBD]
				# Meaning data was NOT read and
				# user pressed 0, so display is NOT working!
				# show that in receipt printer
				gv.test_data_read = False

			string = ''
		else:
			string += char


KBD_THREAD = threading.Thread(target=watch_kbd)


def start_thread():
	'''For starting the thread from main module'''
	KBD_THREAD.start()
