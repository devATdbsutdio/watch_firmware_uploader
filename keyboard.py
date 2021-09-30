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
				# assign test code as the firmware to be uploaded
				vars.curr_firmwa_num = 0
				vars.curr_firmware_name = vars.test_firmware_name
				vars.curr_firmware_path = vars.test_firmware_path
				# update the visual highlither variable for UI
				vars.ui_highlight_test_firmware = "> "
				vars.ui_highlight_prod_firmware = "  "
			elif string == '0' and vars.port_selection_active:
				# assign current debug port as the current port
				vars.curr_serial_debug_port = vars.serial_debug_ports[0]
				# update the visual highlither variable for UI
				vars.ui_highlight_ser_port_0 = "> "
				vars.ui_highlight_ser_port_1 = "  "
			
			if string == '1' and not vars.port_selection_active:
				# assign production code as the firmware to be uploaded
				vars.curr_firmware_num = 1
				vars.curr_firmware_name = vars.prod_firmware_name
				vars.curr_firmware_path = vars.prod_firmware_path
				# update the visual highlither variable for UI
				vars.ui_highlight_test_firmware = "  "
				vars.ui_highlight_prod_firmware = "> "
			elif string == '1' and vars.port_selection_active:
				# assign current debug port as the current port
				vars.curr_serial_debug_port = vars.serial_debug_ports[1]
				# update the visual highlither variable for UI
				vars.ui_highlight_ser_port_0 = "  "
				vars.ui_highlight_ser_port_1 = "> "
			
			if string == 's':
				vars.port_selection_active = not vars.port_selection_active
			elif string == 'p':
				# pull latest firmware
				output = action.execute(vars.git_pull_cmd)
				logger.log(output)
			elif string == 'u':
				# upload current firmware (whcih ever it is, prod or test)
				output = action.execute(vars.upload_cmd)
				logger.log(output)

			string = ''
		else:
			string += c


kbd_thread = threading.Thread(target=watch_kbd)
kbd_thread.start()