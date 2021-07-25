# clock_uploader_machine
## Scripts for installing tools in pi to make assembly-line style firmware uploading to clock dev board.

### Note: 
_Tested in Raspberry PI 3B+ running raspbian:_
````
  `.::///+:/-.        --///+//-:``    pi@firmwareuploader
 `+oooooooooooo:   `+oooooooooooo:    -------------------
  /oooo++//ooooo:  ooooo+//+ooooo.    OS: Raspbian GNU/Linux 10 (buster) armv7l
  `+ooooooo:-:oo-  +o+::/ooooooo:     Host: Raspberry Pi 3 Model B Plus Rev 1.3
   `:oooooooo+``    `.oooooooo+-      Kernel: 5.10.17-v7+
     `:++ooo/.        :+ooo+/.`       Uptime: 4 mins
        ...`  `.----.` ``..           Packages: 549 (dpkg)
     .::::-``:::::::::.`-:::-`        Shell: bash 5.0.3
    -:::-`   .:::::::-`  `-:::-       Terminal: /dev/pts/0
   `::.  `.--.`  `` `.---.``.::`      CPU: BCM2835 (4) @ 1.400GHz
       .::::::::`  -::::::::` `       Memory: 78MiB / 924MiB
 .::` .:::::::::- `::::::::::``::.
-:::` ::::::::::.  ::::::::::.`:::-
::::  -::::::::.   `-::::::::  ::::
-::-   .-:::-.``....``.-::-.   -::-
 .. ``       .::::::::.     `..`..
   -:::-`   -::::::::::`  .:::::`
   :::::::` -::::::::::` :::::::.
   .:::::::  -::::::::. ::::::::
    `-:::::`   ..--.`   ::::::.
      `...`  `...--..`  `...`
            .::::::::::
             `.-::::-`
````

### System pre-requisites:
- [x] System Updated. `sudo apt-get update -y`
- [x] System Upgradeed. `sudo apt-get update -y`
- [x] Add user to the dial out group for serial port access without root. `sudo usermod -a -G dialout pi`
- [x] Install git `sudo apt-get install git -y`
- [x] Python3 `python3 --version`
- [x] Install Pip3 `sudo apt-get install python3-pip -y`
- [ ] ngrok or something else for port forwarding
- [ ] Ansible

### Get the system ready:
1. gti clone
