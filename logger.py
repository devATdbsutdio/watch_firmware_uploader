import logging
import vars

logging.basicConfig(filename=vars.logfile, level=logging.INFO,)

def log(_data):
    for item in _data:
        logging.info(item)
