---
description: README
---

# clock\_uploader\_machine

## Scripts for installing tools in pi to make assembly-line style firmware uploading to clock dev board.

### Note:

_Tested in Raspberry PI 3B+ running raspbian:_

```text
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
```

### System pre-requisites:

* [x] Updated System. `sudo apt-get update -y`
* [x] Upgraded System. `sudo apt-get update -y`
* [x] Add user to the dial out group for serial port access without root. `sudo usermod -a -G dialout pi`
* [x] Install git `sudo apt-get install git -y`
* [x] Check Python3 install \(By default it should be\) `python3 --version`
* [x] Install Pip3 \(It doesn't come bundled in Raspbian\) `sudo apt-get install python3-pip -y`
* [ ] Install [**ngrok**](https://ngrok.com/) \(or something else \) for port forwarding
* [ ] Ansible and workbook if needed

### Get the system ready:

1. git clone ... \[TBD\]

