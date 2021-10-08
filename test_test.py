# #!/usr/bin/env python3


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



import sys
from subprocess import Popen, PIPE, STDOUT

# def run_command(command):
#     process = Popen(command, stdout=PIPE)
#     while True:
#         output = process.stdout.readline()
#         if process.poll() is not None:
#             break
#         if output:
#             print(output.strip())
#     # rc = process.poll()
#     # print(rc)

# # print(run_command(["timeout", "5", "ping", "www.google.com"]))
# # run_command(["timeout", "5", "ping", "www.google.com"])
# run_command(["git", "up"])


def run_command(_cmd):
    # output_buff = [] # outputs are going to append to this list
    process = Popen(_cmd, stdout=PIPE, stderr=STDOUT)

    while process.poll() is None:
        p_output = ""
        try:
            p_output = process.stdout.readline().decode('utf-8')
        except Exception as e:
            pass

        p_error = ""
        try:
            p_error = process.stderr.readline().decode('utf-8')
        except Exception as e:
            pass

        if p_output:
            print(p_output.strip())
            # vars.output_msg_buff.insert(0, p_output)
        if p_error:
            # vars.output_msg_buff.insert(0, p_error)
            print(p_error.strip())

    exitcode = process.poll()
    print(exitcode)

# print(run_command(["timeout", "5", "ping", "www.google.com"]))
run_command(["timeout", "5", "ping", "www.google.com"])
# run_command(["git", "up"])


