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
import logger

# npyscreen.disableColor()
# npyscreen.setTheme(npyscreen.Themes.ColorfulTheme)

# UI main function which is used to draw the terminal UI
def main():
    app = App()
    app.run()



class BufferPagerBox(npyscreen.BoxTitle):
    _contained_widget = npyscreen.BufferPager
    def clearBuffer(self):
        return self.entry_widget.clearBuffer()

    def buffer(self, *args, **values):
        return self.entry_widget.buffer(*args, **values)



class App(npyscreen.NPSApp):
    def main(self):
        term_dims = curses.initscr().getmaxyx()
        height = int(term_dims[0])
        width = int(term_dims[1])

        # logger.log([height])

        form = npyscreen.FormBaseNew(name="WATCH HW SW TESTING UNIT", lines=height)
        

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
            height=11
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
            height=11
            #  max_height=terminal_dimensions()[0] - 10
        )
        # current setting and general info panel
        setting_and_info_panel = form.add(
            Column,
            color="DEFAULT",
            name="CURRENT SETTINGS AND INFO",
            relx=2,
            rely=13,
            max_width=46,
            height=6
        )
        # std out monitor:
        output_pos_y = 19
        std_out_panel = form.add(
            BufferPagerBox, 
            name='PROCESS OUTPUT MONITOR', 
            rely=output_pos_y, 
            height=16,
            editable=False, 
            color='WARNING'
        )

        # watch the form and update values
        while True:
            firmware_sel_panel.values = [
                "* Press \"P\" to pull latest firmwares.",
                "",
                vars.ui_highlight_test_firmware + " [0] : " + vars.test_firmware_name,
                vars.ui_highlight_prod_firmware + " [1] : " + vars.prod_firmware_name,
                "",
                "* Press 0 / 1 to select between TEST",
                "  and PRODUCTION firmwares",
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
                "* The UPDI PORT is Fixed!",
                "* Press \"S\" Key to enable or",
                "disable DEBUG PORT change.", 
                "* Use NUM keys to select a PORT.",
                "* SERIAL DEBUG PORT = Serial",
                "port on the watch module.",
            ]

            setting_and_info_panel.values =[
                "FIRMWARE: " + vars.curr_firmware_name,
                "CHIP: " + vars.target_name,
                # "UPLOADS: " + "refer ext file",
                # "PULL: " + "refer ext file",
                "DUBUG AT: " + vars.curr_serial_debug_port,
                "DUBUG PORT: " + vars.debug_port_status
            ]

            if len(vars.output_msg_buff) >= 1:
                std_out_panel.buffer(vars.output_msg_buff, scroll_end=True)
                vars.output_msg_buff = []
            
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