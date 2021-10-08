logfile = 'log'
exit_code = 0
'''
-- LOADING SETTINGS FILE --
'''
import yaml as yp
import time
import sys

settings = """
- 'EMPTY'
"""

settings_file = 'test_programmer_settings.yaml'
print("Loading settings...")
time.sleep(2)

try:
	with open(settings_file, 'r') as file:
		programmer_settings = yp.safe_load(file)
	settings = programmer_settings
	print('Successfully loaded the ' + settings_file)
	print('\n')
	print(yp.dump(programmer_settings))
	print('\n')
	time.sleep(2)
except Exception as e:
	print(e)
	print('\n\n')
	print('Make sure you have the ' + settings_file + ' in the same directory.')
	time.sleep(1)
	print('I couldn\'t find it')
	time.sleep(1)
	print('Quitting in 2 sec...')
	time.sleep(2)
	sys.exit(1)


# print(settings)
# print(settings['MICROCONTROLLER']['TARGET']['NAME'])
# time.sleep(1)
# sys.exit(1)

ARDUINO_CLI = settings['BINARY']['LOCATION']

target_name = settings['MICROCONTROLLER']['TARGET']['NAME']
test_firmware_path = settings['FIRMWARE']['SKETCHES'][1]
test_firmware_name = test_firmware_path.rsplit('/', 1)[1]
prod_firmware_path = settings['FIRMWARE']['SKETCHES'][0]
prod_firmware_name = prod_firmware_path.rsplit('/', 1)[1]

CORE = settings['MICROCONTROLLER']['TARGET']['CORE']
CHIP = settings['MICROCONTROLLER']['FUSES']['CHIP'] 
CLOCK = settings['MICROCONTROLLER']['FUSES']['CLOCK']
BOD = settings['MICROCONTROLLER']['FUSES']['BOD']
BODMODE = settings['MICROCONTROLLER']['FUSES']['BODMODE']
EEPROM_SAVE = settings['MICROCONTROLLER']['FUSES']['EEPROM_SAVE']
MILLIS = settings['MICROCONTROLLER']['FUSES']['MILLIS']
RESET_PIN = settings['MICROCONTROLLER']['FUSES']['RESET_PIN']
STARTUP_TIME = settings['MICROCONTROLLER']['FUSES']['STARTUP_TIME']
UARTV = settings['MICROCONTROLLER']['FUSES']['UARTV']
PROGRAMMER = settings['MICROCONTROLLER']['FUSES']['PROGRAMMER']


show_raw_cmd = True
output_msg_buff = []
output_msg = ""
old_msg = ""
# ------------------------------

app_launched = True

'''
-- CURRENT FIRMARE SELECTION VAR --
curr_firmware_num = 0/1
0   = signifies that the current uploadable firmware is the test firmware
1   = signifies that the current uploadable firmware is the production firmware

ui_highlight_test_firmware = ">/[SPACE]"
ui_highlight_prod_firmware = ">/[SPACE]"
'>' = moves/updates in ui to point at which firmware is the current active 
firmware to be uploaded
'''
curr_firmware_num = 0
ui_highlight_test_firmware = "> "
ui_highlight_prod_firmware = "  "

curr_firmware_name = test_firmware_name
curr_firmware_path = test_firmware_path

'''
-- Serial ports related vars --
'''
port_selection_active = False
kill_ser_port_watcher_thread = False
serial_debug_ports = ['', '']

# updi_port = serial_debug_ports[0]
updi_port = "/dev/tty.usbserial-A5XK3RJT"
curr_serial_debug_port = serial_debug_ports[1]

ui_highlight_ser_port_0 = "  "
ui_highlight_ser_port_1 = "> "
# ui_highlight_ser_port_2 = "  "


'''
-- COMAMND CONSTRUCTORS --
-- pull cmd
-- upload cmd
'''
git_pull_cmd = ["git", "up"]



FULL_FQBN_WITH_FUSES = CORE +":chip="+str(CHIP)+",clock="+CLOCK+",bodvoltage="+BOD+ \
	",bodmode="+BODMODE+",eesave="+EEPROM_SAVE+",millis="+MILLIS+",resetpin="+ \
	RESET_PIN+",startuptime="+str(STARTUP_TIME)+",uartvoltage="+UARTV

# upload_cmd = ["timeout", "10", "ping", "www.google.com"]

upload_cmd = [
	ARDUINO_CLI, 
	"compile", 
	"-b", 
	FULL_FQBN_WITH_FUSES, 
	curr_firmware_path, 
	"-u", 
	"-p", 
	updi_port, 
	"-P", 
	PROGRAMMER
]

# print(upload_cmd)
# print("\n")
# print(' '.join(upload_cmd))
# time.sleep(10)