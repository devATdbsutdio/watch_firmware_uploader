# from pynput import keyboard

# port_selection_active = False
# spl_key = False
# # pull 

# def on_press(key):
# 	global port_selection_active
# 	global spl_key
# 	try:
# 		spl_key = False
# 		if key.char == 's':
# 			port_selection_active = not port_selection_active
# 			# print(port_selection_active)
# 		# if key.char == 'p':
# 			# port_selection_active = not port_selection_active
# 			# print(port_selection_active)
# 	except AttributeError:
# 		spl_key = True

# # ...or, in a non-blocking fashion:
# listener = keyboard.Listener(on_press=on_press)

# listener.start()

# # while True:
# # 	t = 1


# from key_getter import KeyGetter
# import threading

# def kbd_watcher(): # Test with block=False
#     k = KeyGetter()
#     try:
#         while True:
#             if k.kbhit():
#             	s=1
#                 # print('Got', repr(k.getch(False)))
#     except KeyboardInterrupt:
#         pass

# # runKBDwatcher()

# kbd_watch_routine = threading.Thread(target=kbd_watcher())
# kbd_watch_routine.start()

import sys
import tty
import termios

EOC = '\x03'  # CTRL+C
EOT = '\x04'  # CTRL+D
ESC = '\x1b'
CSI = '['

line = ''

def getchar():
    fd = sys.stdin.fileno()
    attr = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        return sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSANOW, attr)

while True:
    c = getchar()
    if c == EOT or c == EOC:
        # print('exit')
        break
    elif c == ESC:
        if getchar() == CSI:
            x = getchar()
            if x == 'A':
                print('UP')
            elif x == 'B':
                print('DOWN')
    elif c == '\r':
    	# print('>' + c)
        print([line])
        line = ''
        # c = ''
    else:
        line += c