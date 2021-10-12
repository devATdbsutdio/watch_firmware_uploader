#!/usr/bin/env python

'''
MAIN npyscreen UI module showing all the processes. Based on npyscreen APP
'''

# -- GLOBAL IMPORTS -- #
import os
import curses
import sys
import npyscreen
import time
# -- LOCAL MODULE IMPORTS -- #
import global_vars as gv
import log_server_manager

# Start the web log uri getting thread
log_server_manager.start_status_watchdog()
# Start the web log server:
print("weblog server status watch dog started! Starting weblog server thyself...")
time.sleep(2)
log_server_manager.start_server()
time.sleep(2)

import logger
import keyboard as kbd



GREEN = '\033[0;32m'
YELLOW = '\033[0;33m'
RED = '\x1b[1;31m'
RESET = '\033[0m'


sys.path.append(os.path.dirname(os.path.abspath(__file__)))





# Start the keyboard watcher that will implement key press detection and event based business logic
kbd.start_thread()


# npyscreen.disableColor()
# npyscreen.setTheme(npyscreen.Themes.ColorfulTheme)


def main():
    '''UI main function which is used to draw the terminal UI'''
    app = App()
    app.run()


class BufferPagerBox(npyscreen.BoxTitle):
    '''Object for the widget that will show realtime info of processes and alerts'''
    _contained_widget = npyscreen.BufferPager
    def clear_buffer(self):
        '''Clear's the iwdget's buffer, if needed'''
        return self.entry_widget.clear_buffer()

    def buffer(self, *args, **values):
        '''widget's buffer to be filled by realtime data'''
        return self.entry_widget.buffer(*args, **values)



class App(npyscreen.NPSApp):
    '''Mai App class holding all the widget windows'''
    def main(self):
        ''' main app creator '''
        term_dims = curses.initscr().getmaxyx()
        height = int(term_dims[0])
        # width = int(term_dims[1])
        logger.log_info(str(height))

        form = npyscreen.FormBaseNew(name="WATCH HW SW TESTING UNIT", lines=height)

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
            height=18
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
            height=7
        )
        # std out monitor:
        output_pos_y = 20
        std_out_panel = form.add(
            BufferPagerBox,
            name='PROCESS OUTPUT MONITOR',
            rely=output_pos_y,
            height=15,
            editable=False,
            color='WARNING'
        )

        # watch the form and update values
        while True:
            firmware_sel_panel.values = [
                "* Press \"P\" to pull latest firmwares.",
                "",
                gv.ui_highlight_test_firmware + " [0] : " + gv.test_firmware_name,
                gv.ui_highlight_prod_firmware + " [1] : " + gv.prod_firmware_name,
                "",
                "* Press 0 / 1 to select between TEST",
                "  and PRODUCTION firmwares",
                "* Press \"U\" to upload current firmware."
            ]

            # Serial port widget when active ...
            if gv.port_selection_active is True:
                serial_ports_panel.color = "IMPORTANT"
            else:
                serial_ports_panel.color = "DEFAULT"

            serial_ports_panel.values = [
                "UPDI:    " + gv.updi_port,
                "DEBUG: " + gv.ui_highlight_ser_port_0 + gv.serial_debug_ports[0],
                "       " + gv.ui_highlight_ser_port_1 + gv.serial_debug_ports[1],
                "PRINTER: " + gv.printer_port,
                " ",
                " ",
                "* Press \"S\" Key to enable or",
                "disable DEBUG PORT change.",
                "* Use NUM keys to select a PORT.",
                " ",
                "* SERIAL DEBUG PORT = Serial",
                "port on the watch module.",
                " ",
                "* The UPDI PORT is Fixed!",
                "* The PRINTER PORT is Fixed!",
            ]

            setting_and_info_panel.values = [
                "FIRMWARE: " + gv.curr_firmware_name,
                "CHIP: " + gv.target_name,
                "DUBUG AT: " + gv.curr_serial_debug_port,
                "DUBUG PORT: " + gv.debug_port_status,
                "LOG: " + gv.log_server_uri
            ]

            if len(gv.output_msg_buff) >= 1:
                std_out_panel.buffer(gv.output_msg_buff, scroll_end=True)
                gv.output_msg_buff = []

            form.display()


class Column(npyscreen.BoxTitle):
    '''Get necesary data for widget'''
    def resize(self):
        '''Don;t know what to write'''
        self.max_height = int(0.73 * terminal_dimensions()[0])


def terminal_dimensions():
    '''Getting terminal ncurses dimns as tuple for resizing'''
    return curses.initscr().getmaxyx()



if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        gv.kill_ser_port_watcher_thread = True
        gv.kill_web_log_watcher_thread = True
        sys.exit(1)
