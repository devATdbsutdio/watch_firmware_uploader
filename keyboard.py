import threading
import vars
import executer as action
import logger


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
				vars.curr_firmwa_num = 0
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
				# TBD: open DEBUG serial port if it is not opened

				#--- Upload current firmware (which ever it is (prod or test))
				action.execute(vars.upload_cmd, 220)

				# TBD: read serial monitor and print in receipts

				# TBD: close DEBUG serial port if it is not opened
				# logger.log("in Keyboard event still, close serial")

				# TBD: write curr time in success_uploads_log


			string = ''
		else:
			string += c


kbd_thread = threading.Thread(target=watch_kbd)
kbd_thread.start()