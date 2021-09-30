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


import npyscreen


class myTUI(npyscreen.Form):
    def create(self):
        self.hello = self.add(npyscreen.TitleFixedText, name="Say Hello, Hal", value="Hello, Dave")
        self.retort = self.add(npyscreen.Textfield, value="Hal, you are terrible. Read my lips: You suck!")



class ExampleTUI(npyscreen.NPSAppManaged):
    def onStart(self):
        self.addForm("MAIN", myTUI, name="Main TUI Form")

    
    
if __name__ == "__main__":
    npyscreen.wrapper(ExampleTUI().run())