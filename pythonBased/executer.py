'''
Sys shell command executer from python and polling realtime data back to UI
'''

import time
from subprocess import Popen, PIPE, STDOUT
import global_vars as gv
import logger


def execute(_cmd, _timeout):
    '''execute cmd, read chars of returned res and err'''
    cmd_string = ' '.join(_cmd)
    logger.log_info("COMMAND: "+cmd_string)
    # log_info("COMMAND: "+cmd_string)

    process = Popen(_cmd, stdout=PIPE, stderr=STDOUT)
    end_time = time.time() + _timeout
    new_line = ""

    while process.poll() is None:
        # - Timeout
        if time.time() > end_time:
            exit_code = 1
            gv.output_msg_buff.insert(0, "Process timed out...")
            logger.log_error("Process timed out...")
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
                # Output in UI widget window and Log [spl. method]
                if p_output_chars == '\n' or p_output_chars == '\r':
                    #- UI variable & Log
                    gv.output_msg_buff = [new_line.strip()]
                    logger.log_info(new_line.strip())
                    new_line = ""
                else:
                    new_line += p_output_chars
        except Exception as err:
            logger.log_exception(err)

        p_error = ""
        try:
            p_error = process.stderr.readline().decode('utf-8')
            if p_error:
                #- UI and Log file
                gv.output_msg_buff = [p_error.strip()]
                logger.log_error(p_error.strip())
        except Exception as err:
            logger.log_exception(err)

    gv.exit_code = process.poll()
    #- UI & Log 
    gv.output_msg_buff.insert(0, "EXIT_CODE: " + str(gv.exit_code))
    logger.log_info("EXIT_CODE: " + str(gv.exit_code))


# execute(["timeout", "5", "ping", "www.google.com"])
# execute(["git", "up"])
