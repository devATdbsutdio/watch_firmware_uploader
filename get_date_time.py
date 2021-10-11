'''
For preparing formatted string of Date and time to send to uC for time reset
'''

from datetime import datetime


def get_formatted_time():
	''' function for getting curr date time in right format for uC '''
	now = datetime.now()
	week_day = str(datetime.today().weekday())

	# 02:18:19:6:25:06:2021
	hour = str(now.hour)
	minute = str(now.minute)
	second = str(now.second)
	date = str(now.day)
	month = str(now.month)
	year = str(now.year)

	# Arduino uses "\n" this for recoginizng EOL
	formatted_date_time = hour + ":" + minute + ":" + second + ":" + \
						  week_day + ":" + date + ":" + month + ":" + year + "\n"
	return formatted_date_time

def get_std_date_time():
	''' To be used for logs and printing '''
	now = datetime.now()
	std_date_time = now.strftime("%d/%m/%Y %H:%M:%S")
	std_date_time = std_date_time.strip()
	return std_date_time


# print(get_std_date_time())

