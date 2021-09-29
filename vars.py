

app_launched = True

'''
-- CURRENT FIRMARE SELECTION VAR --
curr_firmware_num = 0/1
0   = signifies that the current uploadable firmware is the test firmware
1   = signifies that the current uploadable firmware is the production firmware

ui_highlight_test_firmware = ">/[SPACE]"
ui_highlight_prod_firmware = ">/[SPACE]"
'>' = moves/updates in ui to point at which firmware is the current active firmware to be uploaded
'''
curr_firmware_num = 0
ui_highlight_test_firmware = "> "
ui_highlight_prod_firmware = "  "
test_firmware_name = "test"
test_firmware_path = ""
prod_firmware_name = "prod"
prod_firmware_path = ""
curr_firmware_name = test_firmware_name
curr_firmware_path = test_firmware_path

'''
-- Serial ports related vars --
'''
port_selection_active = False
kill_ser_port_watcher_thread = False
serial_debug_ports = ['', '']

updi_port = serial_debug_ports[0]
curr_serial_debug_port = serial_debug_ports[1]

ui_highlight_ser_port_0 = "  "
ui_highlight_ser_port_1 = "> "
# ui_highlight_ser_port_2 = "  "