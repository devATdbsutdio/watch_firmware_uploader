import logging
import vars

logging.basicConfig(filename=vars.logfile, level=logging.INFO,)

def log(_data):
    if(type(_data) is list):
        for item in _data:
            logging.info(item)

    if(type(_data) is str):
        logging.info(_data)