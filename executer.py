#!/usr/bin/env python

import sys
from subprocess import Popen, PIPE, STDOUT
import vars
import logger
import time

# def execute(_cmd):
#     output = [] # outputs are going to append to this list
#     with Popen(_cmd, stdout=PIPE, stderr=STDOUT, bufsize=1, universal_newlines=True) as p:
#         for out in p.stdout:
#             output.append(out)
#         try:
#             for err in p.stderr:
#               output.append(err)
#         except Exception as e:
#             output.append("OK!")
#             pass
#     return output


def execute(_cmd, _timeout):
    cmd_string = ' '.join(_cmd)
    logger.log("\nCOMMAND: "+cmd_string)

    process = Popen(_cmd, stdout=PIPE, stderr=STDOUT)
    endTime = time.time() + _timeout
    new_line = ""

    while process.poll() is None:
        # - Timeout
        if time.time() > endTime:
            exitcode = 1
            vars.output_msg_buff.insert(0, "Process timed out...")
            logger.log("Process timed out...")
            process.kill()
            break

        p_output_chars = ""
        try:
            p_output_chars = process.stdout.read(1).decode('utf-8')
            # We are not using readline() but read(1) 1 charat a time as
            # we the arduino-cli upload command produces a progress bar, 
            # something like: [=====]100%
            # where the characters are thrown in 1 line, so readline() 
            # produces weird visuals. 

            if p_output_chars:
                #- Output in UI windget window and Log [spl. method]
                if p_output_chars == '\n' or p_output_chars == '\r':
                    #- UI
                    vars.output_msg_buff.insert(0, new_line.strip())
                    #- log
                    logger.log(new_line.strip())
                    new_line = ""
                else:
                    new_line += p_output_chars
        except Exception as e:
            pass

        p_error = ""
        try:
            p_error = process.stderr.readline().decode('utf-8')
            if p_error:
                #- UI
                # output in UI windget window
                vars.output_msg_buff.insert(0, p_error.strip())
                #- Log
                logger.log(p_error.strip())
        except Exception as e:
            pass

    vars.exit_code = process.poll()
    #- UI - Output in UI windget window
    vars.output_msg_buff.insert(0, "EXIT_CODE: " + str(vars.exit_code))
    #- Log
    logger.log("EXIT_CODE: "+str(vars.exit_code))
    

# execute(["timeout", "5", "ping", "www.google.com"])
# execute(["git", "up"])

