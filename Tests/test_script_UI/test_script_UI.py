# -- GLOBAL IMPORTS -- #
import threading
import curses
import sys
import npyscreen
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# npyscreen.disableColor()

# UI main function which is used to draw the terminal UI
def main():
    app = App()
    app.run()


class App(npyscreen.NPSApp):
    def main(self):
        form = npyscreen.FormBaseNew(name="WATCH HW SW TESTING UNIT")

        # FIRMWARE LIST
        # SERIAL PORT LIST
        # OPERATION INFO
        # SERIAL & PROCESS INFO MONITOR
        # GENERAL INFO (TARGET, CURR SW, TOTAL UPLOADS)

        # Android device stat board
        firmware_sel_panel = form.add(
            Column,
            name="FIRMWARES",
            relx=2,
            rely=2,
            max_width=30,
            height=4
            #  max_height=terminal_dimensions()[0] - 10
        )

        # watch the form and update values
        while True:
            firmware_sel_panel.values = [
                "TEST:",
                "PRODUCTION:",
            ]

            form.display()


class Column(npyscreen.BoxTitle):
    def resize(self):
        self.max_height = int(0.73 * terminal_dimensions()[0])


def terminal_dimensions():
    return curses.initscr().getmaxyx()   



if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(1)