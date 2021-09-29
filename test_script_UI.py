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
import vars
import keyboard as kbd
import serialport_manager as spm

# npyscreen.disableColor()
# npyscreen.setTheme(npyscreen.Themes.ColorfulTheme)

# UI main function which is used to draw the terminal UI
def main():
    app = App()
    app.run()


class App(npyscreen.NPSApp):
    def main(self):
        form = npyscreen.FormBaseNew(name="WATCH HW SW TESTING UNIT")

        # FIRMWARE LIST (p to pull and u  upload)
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
            height=13
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
            height=13
            #  max_height=terminal_dimensions()[0] - 10
        )
        # current setting and general info panel
        setting_and_info_panel = form.add(
            Column,
            color="DEFAULT",
            name="CURRENT SETTINGS AND INFO",
            relx=2,
            rely=15,
            max_width=84,
            height=4
        )
        # std out monitor:
        std_out_panel = form.add(
            Column,
            color="DEFAULT",
            name="PROCESS OUTPUT MONITOR",
            relx=2,
            rely=19,
            max_width=84,
            height=10
        )

        # watch the form and update values
        while True:
            firmware_sel_panel.values = [
                vars.ui_highlight_test_firmware + " [0] TEST  CODE: " + vars.test_firmware_name,
                vars.ui_highlight_prod_firmware + " [1] PRODUCTION: " + vars.prod_firmware_name,
                "",
                "* Press 0 / 1 to make the TEST/PRODUCTION",
                "  code base respectively, as the current ", 
                "  uploadable firmware.",
                "* For example, select the TEST code as",
                "  uploadable firmware when checking HW",
                "  components.",
                "* Press \"P\" to pull latest firmwares.",
                "* Press \"U\" to upload current firmware."
            ]

            
            # Serial port widget when active ...
            if vars.port_selection_active == True:
                serial_ports_panel.color="IMPORTANT"
            else:
                serial_ports_panel.color="DEFAULT"

            serial_ports_panel.values = [
                "UPDI:    " + vars.updi_port,
                "DEBUG: " + vars.ui_highlight_ser_port_0 + vars.serial_debug_ports[0],
                "       " + vars.ui_highlight_ser_port_1 + vars.serial_debug_ports[1],
                "",
                "* The UPDI PORT is Fixed!",
                "",
                "* Press \"S\" Key to enable or",
                "disable DEBUG PORT change.", 
                "* Use NUM keys to select a PORT.",
                "* SERIAL DEBUG PORT = Serial",
                "port on the watch module.",
            ]

            setting_and_info_panel .values =[
                "CURRENT FIRMWARE: " + vars.curr_firmware_name + "   TARGET CHIP: " + "will come from settings ymal",
                "TOTAL UPLOADS: " + "refer ext file" + "   DUBUG AVAILABLE AT: " + vars.curr_serial_debug_port
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
        vars.kill_ser_port_watcher_thread = True
        sys.exit(1)