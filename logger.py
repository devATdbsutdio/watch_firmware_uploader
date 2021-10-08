#!/usr/bin/env python

import logging
import global_vars as gv

logging.basicConfig(filename=gv.logfile, level=logging.INFO,)

def log(_data):
    if(type(_data) is list):
        for item in _data:
            logging.info(item)

    if(type(_data) is str):
        logging.info(_data)