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

        # FIRMWARE LIST
        # SERIAL PORT LIST
        # SERIAL & PROCESS INFO MONITOR
        # GENERAL INFO (TARGET, CURR SW, TOTAL UPLOADS)

        # Firmware list display widget
        firmware_sel_panel = form.add(
            Column,
            color="DEFAULT",
            name="FIRMWARES",
            relx=2,
            rely=2,
            max_width=45,
            height=11
            #  max_height=terminal_dimensions()[0] - 10
        )
        # Serial port list display widget
        serial_ports_panel = form.add(
            Column,
            color="DEFAULT",
            name="SERIAL PORTS",
            relx=50,
            rely=2,
            max_width=35,
            height=11
            #  max_height=terminal_dimensions()[0] - 10
        )

        # watch the form and update values
        while True:
            firmware_sel_panel.values = [
                "[0] TEST  CODE:",
                "[1] PRODUCTION:",
                "",
                "** Press 0 / 1 to make the TEST / PRODUCTION",
                "   code base as the current uploadable", 
                "   firmware, respectively.",
                "** For example, select the TEST code as the",
                "   uploadable firmware when checking the HW",
                "   components."
            ]
            
            # Serial port widget when active ...
            if kbd.port_selection_active == True:
                serial_ports_panel.color="IMPORTANT"
            else:
                serial_ports_panel.color="DEFAULT"


            serial_ports_panel.values = [
                "UPDI  PORT:",
                "DEBUG PORT:",
                "",
                "",
                "",
                "** The UPDI port is Fixed!",
                "** Attach the Serial Port of",
                "   the watch and press \"S\"",
                "   to select the DEBUG port."
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