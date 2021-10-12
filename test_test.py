#!/usr/bin/env python3


# import sys
# from subprocess import Popen, PIPE, STDOUT

# import logging

# LOG_FILENAME = 'log'

# logging.basicConfig(filename=LOG_FILENAME, level=logging.INFO,)
# # 
# with Popen(["rm", ".log"], stdout=PIPE, stderr=STDOUT, bufsize=1, universal_newlines=True) as p:
#     for out in p.stdout:
#         logging.info(out)
#     try:
#         for err in p.stderr:
#             logging.error(err)
#     except Exception as e:
#         logging.info("OK!")
#         pass


# import npyscreen


# class myTUI(npyscreen.Form):
#     def create(self):
#         self.hello = self.add(npyscreen.TitleFixedText, name="Say Hello, Hal", value="Hello, Dave")
#         self.retort = self.add(npyscreen.Textfield, value="Hal, you are terrible. Read my lips: You suck!")



# class ExampleTUI(npyscreen.NPSAppManaged):
#     def onStart(self):
#         self.addForm("MAIN", myTUI, name="Main TUI Form")

    
    
# if __name__ == "__main__":
#     npyscreen.wrapper(ExampleTUI().run())



# import sys
# from subprocess import Popen, PIPE, STDOUT
# import time

# # def run_command(command):
# #     process = Popen(command, stdout=PIPE)
# #     while True:
# #         output = process.stdout.readline()
# #         if process.poll() is not None:
# #             break
# #         if output:
# #             print(output.strip())
# #     # rc = process.poll()
# #     # print(rc)

# # # print(run_command(["timeout", "5", "ping", "www.google.com"]))
# # # run_command(["timeout", "5", "ping", "www.google.com"])
# # run_command(["git", "up"])


# def run_command(_cmd):
#     # output_buff = [] # outputs are going to append to this list
#     process = Popen(_cmd, stdout=PIPE, stderr=STDOUT)
#     endTime=time.time()+2

#     while process.poll() is None:
#         if time.time() > endTime:
#             exitcode = 1
#             print(exitcode)
#             print("Timed out!")
#             process.kill()
#             break

#         p_output = ""
#         try:
#             p_output = process.stdout.readline().decode('utf-8')
#         except Exception as e:
#             pass

#         p_error = ""
#         try:
#             p_error = process.stderr.readline().decode('utf-8')
#         except Exception as e:
#             pass

#         if p_output:
#             print(p_output.strip())
#             # vars.output_msg_buff.insert(0, p_output)
#         if p_error:
#             # vars.output_msg_buff.insert(0, p_error)
#             print(p_error.strip())

#     exitcode = process.poll()
#     print(exitcode)

# # print(run_command(["timeout", "5", "ping", "www.google.com"]))
# run_command(["timeout", "5", "ping", "www.google.com"])
# # run_command(["git", "up"])



# import vars
# import executer as action
# import logger

# vars.updi_port = "updi_port"

# print(vars.upload_cmd)
# print(' '.join(vars.upload_cmd))
# logger.log(' '.join(vars.upload_cmd))
# logger.log("")

# action.execute(vars.upload_cmd, 120)


# from PIL import Image
# from thermalprinter import ThermalPrinter


# printer = ThermalPrinter(port='/dev/tty.usbserial-AC01O32Q')

# # Line feeds
# printer.feed(2)

# printer.out('Bold', bold=True)
# printer.out('Double height', double_height=True)
# printer.out('Double width', double_width=True)
# printer.out('Inverse', inverse=True)
# # printer.out('Rotate 90°', rotate=True, codepage=CodePage.ISO_8859_1)
# printer.out('Strike', strike=True)
# printer.out('Underline', underline=1)
# printer.out('Upside down', upside_down=True)

# # Line feeds
# printer.feed(6)



# Python program to get the
# path of the script
 
 
# import os
 
# # Get the current working 
# # directory (CWD) 
# cwd = os.getcwd() 
# print("Current Directory:", cwd)
 
# # Get the directory of
# # script
# script_path = os.path.realpath(__file__)
# print("Script Path:", script_path)
# script_dir = script_path[:script_path.rindex('/')+1]
# print("Script Dir:", script_dir)

from subprocess import Popen, PIPE, STDOUT
# process = Popen(["cd", "/home/pi/Arduino/sketchbook/clock_firmware_productio", "&&", "git", "up", "&&", "cd", "~"], stdout=PIPE, stderr=STDOUT)
process = Popen(["git", "-C", "/home/pi/Arduino/sketchbook/clock_firmware_productio", "pull"], stdout=PIPE, stderr=STDOUT)
new_line = ""
while process.poll() is None:
    p_output_chars = ""
    try:
        p_output_chars = process.stdout.read(1).decode('utf-8')
        if p_output_chars:
            if p_output_chars == '\n' or p_output_chars == '\r':
                print(new_line.strip())
                new_line = ""
            else:
                new_line += p_output_chars
    except Exception as err:
        print(err)