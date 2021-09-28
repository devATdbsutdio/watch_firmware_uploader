from pynput import keyboard

port_selection_active = False
spl_key = False
# pull 

def on_press(key):
	global port_selection_active
	global spl_key
	try:
		spl_key = False
		if key.char == 's':
			port_selection_active = not port_selection_active
			# print(port_selection_active)
		# if key.char == 'p':
			# port_selection_active = not port_selection_active
			# print(port_selection_active)
	except AttributeError:
		spl_key = True

# ...or, in a non-blocking fashion:
listener = keyboard.Listener(on_press=on_press)

listener.start()

# while True:
# 	t = 1