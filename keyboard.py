import threading
import vars

port_selection_active = False
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
	global port_selection_active

	while True:
		c = getchar()

		if c == EOT or c == EOC or c == ESC:
			break
		elif c == '\r':
			# print(string)
			if string == '0' and not port_selection_active:
				# assign test code as the firmware to be uploaded
				vars.curr_firmwa_num = 0
				# update the visual highlither variable for UI
				vars.ui_highlight_test_firmware = "> "
				vars.ui_highlight_prod_firmware = "  "
			if string == '1' and not port_selection_active:
				# assign production code as the firmware to be uploaded
				vars.curr_firmware_num = 1
				# update the visual highlither variable for UI
				vars.ui_highlight_test_firmware = "  "
				vars.ui_highlight_prod_firmware = "> "
			if string == 's':
				port_selection_active
				port_selection_active = not port_selection_active
				# print(port_selection_active)
			# else if key is not 0-9 or ENTER or U

			string = ''
		else:
			string += c


kbd_thread = threading.Thread(target=watch_kbd)
kbd_thread.start()