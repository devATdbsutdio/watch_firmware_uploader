# #!/usr/bin/env python
# # encoding: utf-8

# import npyscreen, curses

# class MyTestApp(npyscreen.NPSAppManaged):
#     def onStart(self):
#         self.registerForm("MAIN", MainForm())

# class MainForm(npyscreen.FormWithMenus):
#     def create(self):
#         self.add(npyscreen.TitleText, name = "Text:", value= "Just some text." )
#         self.how_exited_handers[npyscreen.wgwidget.EXITED_ESCAPE]  = self.exit_application    
        
#         # The menus are created here.
#         self.m1 = self.add_menu(name="Main Menu", shortcut="^M")
#         self.m1.addItemsFromList([
#             ("Display Text", self.whenDisplayText, None, None, ("some text",)),
#             ("Just Beep",   self.whenJustBeep, "e"),
#             ("Exit Application", self.exit_application, "é"),
#         ])
        
#         self.m2 = self.add_menu(name="Another Menu", shortcut="b",)
#         self.m2.addItemsFromList([
#             ("Just Beep",   self.whenJustBeep),
#         ])
        
#         self.m3 = self.m2.addNewSubmenu("A sub menu", "^F")
#         self.m3.addItemsFromList([
#             ("Just Beep",   self.whenJustBeep),
#         ])        

#     def whenDisplayText(self, argument):
#        npyscreen.notify_confirm(argument)

#     def whenJustBeep(self):
#         curses.beep()

#     def exit_application(self):
#         curses.beep()
#         self.parentApp.setNextForm(None)
#         self.editing = False
#         self.parentApp.switchFormNow()

# def main():
#     TA = MyTestApp()
#     TA.run()


# if __name__ == '__main__':
#     main()


import keyboard  # using module keyboard
while True:  # making a loop
    try:  # used try so that if user pressed other than the given key error will not be shown
        if keyboard.is_pressed('q'):  # if key 'q' is pressed 
            print('You Pressed A Key!')
            break  # finishing the loop
    except:
        break  # if user pressed a key other than the given key the loop will break

# from pynput import keyboard

# def on_press(key):
#     try:
#         print('alphanumeric key {0} pressed'.format(
#             key.char))
#     except AttributeError:
#         print('special key {0} pressed'.format(
#             key))

# def on_release(key):
#     print('{0} released'.format(
#         key))
#     if key == keyboard.Key.esc:
#         # Stop listener
#         return False

# # Collect events until released
# # with keyboard.Listener(
# #         on_press=on_press,
# #         on_release=on_release) as listener:
# #     listener.join()

# # ...or, in a non-blocking fashion:
# listener = keyboard.Listener(
#     on_press=on_press,
#     on_release=on_release)
# listener.start()

# while True:
#     s = 1