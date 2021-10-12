'''
find log web server details and use in UI
'''

import threading
import time
from subprocess import Popen, PIPE, STDOUT
import ifaddr
import global_vars as gv


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
	''' intended to return the grep search reslt '''
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
	frontail_port = 0 # we do not know yet
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
		fontail_port = shell_res[start_idx:end_idx]
	else:
		fontail_port = "0"
	return fontail_port


# --- Main grabber functions--- #
def watch_log_server():
	'''Thread to update uri variables'''
	#  only once on launch ...
	self_ip_addr = get_ip_addrs('en0')[0] # if multiple? [TBD]

	while True:
		if gv.kill_web_log_watcher_thread:
			break

		log_server_port = get_log_server_port(CMD_SEARCH_CMD)

		if log_server_port == "0":
			gv.log_server_uri = "No Log Server running!"
		else:
			gv.log_server_uri = "http://" + self_ip_addr + ":" + log_server_port

		# print(gv.log_server_uri)
		time.sleep(1)


LOG_SERVER_WATCHER = threading.Thread(target=watch_log_server)

def start_thread():
	'''For starting the thread from main module'''
	LOG_SERVER_WATCHER.start()

# start_thread()
