'''
find log web server details and use in UI
'''


import threading
import time
import os
import sys
import subprocess
from subprocess import Popen, PIPE, STDOUT
import ifaddr
import global_vars as gv


# SET THE Gloabl params for some system execs like 'rm' and 'touch' etc. to be used here for log file handling
p = Popen(["which", "rm"], stdout=PIPE, stderr=STDOUT)
rm = p.stdout.readline().decode('utf-8').strip('\n\r')
p = Popen(["which", "touch"], stdout=PIPE, stderr=STDOUT)
touch = p.stdout.readline().decode('utf-8').strip('\n\r')


# --- Launch web log server --- #
SPAWN_FRONTAIL_LOG_FILE_WATCHER = [
		  gv.frontail_path,
		  "--ui-hide-topbar",
		  "--theme", "dark",
		  "--disable-usage-stats",
		  "-p",
		  gv.frontail_init_port,
		  "<log_file_path>"
]

def start_server():
	'''For spawning frontail server web log server for logfile'''

	# [TBD] Fix why I can't get frontail path from here
	process = Popen(['which', 'frontail'], stdout=PIPE, stderr=STDOUT)
	gv.frontail_path = process.stdout.readline().decode('utf-8').strip('\n\r')
	print(gv.frontail_path)

	SPAWN_FRONTAIL_LOG_FILE_WATCHER[0] = gv.frontail_path

	script_path = os.path.realpath(__file__)
	script_dir = script_path[:script_path.rindex('/')+1]
	gv.logfile_path = script_dir + gv.logfile_name

	print("EXPECTED LOG AT: " + gv.logfile_path + "\n")

	SPAWN_FRONTAIL_LOG_FILE_WATCHER[7] = gv.logfile_path

	if os.path.exists(gv.logfile_path):
		# file exists, delete and create
		print("Old log file found. Deleting it...")
		subprocess.call([rm, gv.logfile_path]);
		# subprocess.call(['ls', '-l']);
		time.sleep(1)
		print("Creatig an EMPTY log file again...")
		subprocess.call([touch, gv.logfile_path]);
		# subprocess.call(['ls', '-l']);
		time.sleep(1)
	else:
		# file doesn't exist, just create
		print("No Old log file found. Creatig an EMPTY one...")
		subprocess.call([touch, gv.logfile_path]);
		# subprocess.call(['ls', '-l']);
		time.sleep(1)
	# [TBD] git add and git commit

	print(' '.join(SPAWN_FRONTAIL_LOG_FILE_WATCHER))

	front_tail_process_spawner = Popen(SPAWN_FRONTAIL_LOG_FILE_WATCHER, stdout=PIPE, stderr=STDOUT)

	if front_tail_process_spawner.poll() is None:
		print("'frontail' web logserver has started!")
		time.sleep(1)
	else:
		print("'frontail' web logserver have NOT been started!")
		time.sleep(1)




# --- Get IP address of the machine --- #
IFACES = ifaddr.get_adapters()

def get_ip_addrs(_iface):
    '''for getting the local ip address list on certain interface'''
    ip_list = []

    for iface in IFACES:
        if iface.nice_name == _iface:
            for ipadd in iface.ips:
                ip_list.append(ipadd.ip)
    return ip_list



# --- Get port used by log server "frontail" --- #
CMD_SEARCH_CMD = "ps aux | grep frontail"

def get_shell_res(_cmd):
	''' intended to return the grep search result '''
	process = Popen(_cmd, shell=True, stdout=PIPE, stderr=STDOUT)
	output = process.communicate()
	shell_res = output[0].decode('utf-8').strip()
	return shell_res

def find_char_idx(_str, _chr):
	''' for character idx search '''
	for i, ltr in enumerate(_str):
		if ltr == _chr:
			yield i

def get_log_server_port(_cmd):
	''' intended to return the grep search reslt '''
	frontail_port = "0" # we do not know yet
	shell_res = get_shell_res(_cmd)
	char_idx_list = list(find_char_idx(shell_res, '-'))
	# print(char_idx_list)

	start_idx = 0
	end_idx = 0

	# check chars at idx+1 from the list of indices
	# if the char is 'p' means it was potentially '-p'
	for char_idx in char_idx_list:
		if shell_res[char_idx+1] == 'p':
			# print("found port reference")
			start_idx = char_idx+3
			end_idx = start_idx+4

	if start_idx != 0 and end_idx != 0:
		frontail_port = shell_res[start_idx:end_idx]
	else:
		frontail_port = "0"
	return frontail_port


# --- Main grabber functions--- #
def watch_log_server():
	'''Thread to update uri variables'''
	#  only once on launch ...
	
	if sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
		self_ip_addr = get_ip_addrs('wlan0')[0] 
	
	if sys.platform.startswith('darwin'):
		self_ip_addr = get_ip_addrs('en0')[0]

	while True:
		if gv.kill_web_log_watcher_thread:
			break

		log_server_port = get_log_server_port(CMD_SEARCH_CMD)

		if log_server_port == "0":
			gv.log_server_uri = "No Log Server running!"
		else:
			gv.log_server_uri = "http://" + self_ip_addr + ":" + log_server_port
		time.sleep(1)


LOG_SERVER_WATCHER = threading.Thread(target=watch_log_server)

def start_status_watchdog():
	'''For starting the thread from main module'''
	LOG_SERVER_WATCHER.start()

# start_thread()
