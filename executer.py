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


def execute(_cmd):
    # Show raw cmd if set as "True" in vars.py
    if vars.show_raw_cmd:
        cmd_string = ' '.join(_cmd)
        vars.output_msg_buff.insert(0, "CURR CMD: "+cmd_string+"\n")
        vars.output_msg_buff.insert(0, "")
        # show raw command in log file
        logger.log("\nCOMMAND: "+cmd_string)

    process = Popen(_cmd, stdout=PIPE, stderr=STDOUT)

    while process.poll() is None:
        p_output = ""
        try:
            p_output = process.stdout.readline().decode('utf-8')
            if p_output:
                # - UI output
                # output in UI windget window
                vars.output_msg_buff.insert(0, p_output.strip())

                # - logging
                logger.log(p_output.strip())
        except Exception as e:
            pass

        p_error = ""
        try:
            p_error = process.stderr.readline().decode('utf-8')
            if p_error:
                # - UI output
                # output in UI windget window
                vars.output_msg_buff.insert(0, p_error.strip())

                # - logging
                logger.log(p_error.strip())
        except Exception as e:
            pass

    exitcode = process.poll()
    # print(exitcode)
    # output in UI windget window
    vars.output_msg_buff.insert(0, exitcode)
    # create a gap in log file
    logger.log("\n\n")
    

# execute(["timeout", "5", "ping", "www.google.com"])
# execute(["git", "up"])