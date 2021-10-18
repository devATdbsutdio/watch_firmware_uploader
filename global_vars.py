'''All the variables goes here which will be exchanged between modules'''

import time
import os
import sys
from subprocess import Popen, PIPE, STDOUT
import yaml as yp




logfile_name = 'uploader_scpt.log' # Get absolute path from the log_server_manager
logfile_path = ""
log_server_uri = "" 
kill_web_log_watcher_thread = False

frontail_path = "frontail" # Get absolute path from the log_server_manager
frontail_init_port = "3060"




''' -- '''
exit_code = 0


'''
-- LOADING SETTINGS FILE --
'''
settings = """
- 'EMPTY'
"""

script_path = os.path.realpath(__file__)
script_dir = script_path[:script_path.rindex('/')+1]
settings_file = script_dir + 'programmer_settings.yaml'
# settings_file = script_dir + 'test_programmer_settings.yaml'
# settings_file = 'test_programmer_settings.yaml'
print("\n\nLoading settings...")

try:
	with open(settings_file, 'r') as setting_f:
		settings = yp.safe_load(setting_f)
	print('Successfully loaded the ' + settings_file)
	print('\n')
	print(yp.dump(settings))
	print('\n')
	time.sleep(1)
except OSError as err:
	print(err)
	print('\n\n')
	print('Quitting in 1 sec...')
	time.sleep(1)
	sys.exit(1)
except IOError as err:
	print(err)
	print('\n\n')
	print('Make sure you have the ' + settings_file + ' in the same directory.')
	time.sleep(1)
	print('Couldn\'t find it')
	print('Quitting in 1 sec...')
	time.sleep(1)
	sys.exit(1)



printer_port = ""


'''
-- ALL THE VARIABLES TO BE USED ACROSS MODULES --
'''

ARDUINO_CLI = settings['BINARY']['LOCATION']

target_name = settings['MICROCONTROLLER']['TARGET']['NAME']
test_firmware_path = settings['FIRMWARE']['SKETCHES'][1]
test_firmware_name = test_firmware_path.rsplit('/', 1)[1]
prod_firmware_path = settings['FIRMWARE']['SKETCHES'][0]
prod_firmware_name = prod_firmware_path.rsplit('/', 1)[1]

print("prod firmware loc: " + prod_firmware_path)
print("test firmware loc: " + test_firmware_path)


#-- For testing on mac, firmwares are at diff paths
if sys.platform.startswith('darwin'):
	# Replace arduino cli path, hw firmware paths (are loacted in proj dir)

	process = Popen(["which", "arduino-cli"], stdout=PIPE, stderr=STDOUT)
	ARDUINO_CLI = process.stdout.readline().decode('utf-8').strip('\n\r ')
	
	script_path = os.path.realpath(__file__)
	script_dir = script_path[:script_path.rindex('/')]
	mac_proj_dir = script_dir[:script_dir.rindex('/')]
	mac_arduino_firmware_loc = mac_proj_dir + "/Arduino/clock_firmware_production"
	prod_firmware_path = mac_arduino_firmware_loc
	test_firmware_path = prod_firmware_path + '/Tests/components_check'

	print("\nSince we are on mac, new firmware paths are:")
	print("arduino-cli loc: " + ARDUINO_CLI)
	print("prod firmware loc: " + prod_firmware_path)
	print("test firmware loc: " + test_firmware_path)




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


output_msg_buff = []
output_msg = ""
old_msg = ""
# ------------------------------

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
updi_ftdi_id = "A10KHTR4"
thermal_printer_serial_chip_id = "AI05HDSG"

port_selection_active = False
kill_ser_port_watcher_thread = False
serial_debug_ports = ['', '']

updi_port = serial_debug_ports[0]
# updi_port = "/dev/tty.usbserial-A5XK3RJT"
curr_serial_debug_port = serial_debug_ports[1]
last_serial_debug_port = curr_serial_debug_port

ui_highlight_ser_port_0 = "  "
ui_highlight_ser_port_1 = "> "
# ui_highlight_ser_port_2 = "  "

debug_channel_open = False
debug_port_status = "Closed"
test_data_read = False

heading_identifier = '[H]'
test_log_dict = []
# printer_port = '/dev/tty.usbserial-AI05HDSG'

'''
-- COMAMND CONSTRUCTORS --
-- pull cmd
-- upload cmd
'''





git_pull_cmd = ["git", "-C", prod_firmware_path, "pull"]



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
print("\n")
print(' '.join(upload_cmd))
print("\n")
time.sleep(5)


app_launched = True
