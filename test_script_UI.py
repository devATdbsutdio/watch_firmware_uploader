#!/usr/bin/env python

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\x1b[1;31m'
RESET='\033[0m'

# -- GLOBAL IMPORTS -- #
import threading
import curses
import sys
import npyscreen
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# -- LOCAL MODULE IMPORTS -- #
# import preloads as pl
import keyboard as kbd

# npyscreen.disableColor()
# npyscreen.setTheme(npyscreen.Themes.ColorfulTheme)

# UI main function which is used to draw the terminal UI
def main():
    app = App()
    app.run()


class App(npyscreen.NPSApp):
    def main(self):
        form = npyscreen.FormBaseNew(name="WATCH HW SW TESTING UNIT")

        # FIRMWARE LIST (p to pull and u to upload)
        # SERIAL PORT LIST (port changing mechanism)
        # GENERAL INFO (TARGET, CURR SW, TOTAL UPLOADS)
        # SERIAL & PROCESS INFO MONITOR

        # Firmware list display widget
        firmware_sel_panel = form.add(
            Column,
            color="DEFAULT",
            name="FIRMWARES",
            relx=2,
            rely=2,
            max_width=46,
            height=12
            #  max_height=terminal_dimensions()[0] - 10
        )
        # Serial port list display widget
        serial_ports_panel = form.add(
            Column,
            color="DEFAULT",
            name="SERIAL PORTS",
            relx=49,
            rely=2,
            max_width=37,
            height=12
            #  max_height=terminal_dimensions()[0] - 10
        )

        # watch the form and update values
        while True:
            firmware_sel_panel.values = [
                "[0] TEST  CODE:",
                "[1] PRODUCTION:",
                "",
                "* Press 0 / 1 to make the TEST / PRODUCTION",
                "  code base respectively, as the current ", 
                "  uploadable firmware.",
                "* For example, select the TEST code as the",
                "  uploadable firmware when checking the HW",
                "  components."
            ]
            
            # Serial port widget when active ...
            if kbd.port_selection_active == True:
                serial_ports_panel.color="IMPORTANT"
            else:
                serial_ports_panel.color="DEFAULT"


            serial_ports_panel.values = [
                "UPDI UPLOAD PORT: ",
                "SERIAL DEBUG PORT:",
                "",
                "",
                "* The UPDI UPLOAD PORT is Fixed!",
                "* Press \"S\" Key to enable /",
                "disable DEBUG PORT change.", 
                "* Use NUM keys to select a PORT.",
                "* SERIAL DEBUG PORT = Serial",
                "port on the watch module.",
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