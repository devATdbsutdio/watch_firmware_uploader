'''
Exposing easy logging levels through functions for other modules
'''

import logging
import global_vars as gv

logging.basicConfig(filename=gv.logfile_path, #[TBD] logfile_path <- log_servewr_manager module
                    format='%(asctime)s.%(msecs)03d %(levelname)s %(message)s',
                    level=logging.DEBUG, datefmt='%Y-%m-%d %H:%M:%S')

logger = logging.getLogger()
print = logger.info

def log_info(_data):
    '''info logger for strings and lists'''
    if isinstance(_data, list):
        for item in _data:
            logging.info(item)
    if isinstance(_data, str):
        logging.info(_data)


def log_error(_data):
    '''error logger for strings and lists'''
    if isinstance(_data, list):
        for item in _data:
            logging.error(item)
    if isinstance(_data, str):
        logging.error(_data)


def log_warning(_data):
    '''warning logger for strings and lists'''
    if isinstance(_data, list):
        for item in _data:
            logging.warning(item)
    if isinstance(_data, str):
        logging.warning(_data)

def log_exception(_data):
    '''exception logger for strings and lists'''
    if isinstance(_data, list):
        for item in _data:
            logging.exception(item)
    if isinstance(_data, str):
        logging.exception(_data)
