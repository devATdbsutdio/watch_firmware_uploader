---
description: >-
  How to prepare a fresh install on raspberry pi. Installations needed to run
  the main installer later
---

# General First steps ↓

Update and upgrade the system \(if you haven't done already so\): 

```
$ sudo apt-get update -y
$ sudo aot-get upgrade -y
```

> Note: If you are in China, you might need to install a VPN in your raspbian to have quick handshakes with GitHub later. Recommendation for an easy to use cli base VPN would be [**express-vpn**](https://www.expressvpn.com/support/vpn-setup/app-for-raspberry-pi/)**.** 🤨

Next is to Install git:

```bash
$ sudo apt-get install git -y
```

Now check python3 installation and install pip3:

> If it is not installed, update to Python3

```bash
$ which python3
```

This should yield:

```bash
$ /<PATH to Python3>/python3
```

On a first fresh install, if you run:

```bash
$ which pip3
# nothing
```

So install pip3:

```bash
$ sudo apt-get install python3-pip -y
```

To have serial port access from scripts that are run by the current user, in linux, you need to add that user to `dialout` group:

```bash
$ sudo usermod -a -G dialout <USER>
# example: My user is defualt pi
$ sudo usermod -a -G dialout pi
```

Finally:

```bash
$ sudo reboot
```

System is ready for next steps. 🤓

### 

### Extra configuration for screen: 

So I will be using, for this terminal, the [**4" square display from wave-share**](https://www.waveshare.com/4inch-dpi-lcd-c.htm). It is not a must to have but if you want it as well, the instructions to set-up the PI for the display can be found on the [**wiki**](https://www.waveshare.com/wiki/4inch_DPI_LCD_%28C%29)**.** 

> NOTE: I'm not going to be using touch functionality for this screen as the OS I'm using is raspbian Lite   terminal version. For inputs I will be using a custom keyboard attached to it. So I will be skipping the touch setup for this.

![ 4&quot; square display from wave-share](../.gitbook/assets/screenshot-2021-07-26-at-7.36.36-pm.png)

Edit `/boot/config.txt` :

```bash
$ sudo nano /boot/config.txt
```

At the end of the file, add the following:

```bash
gpio=0-9=a2
gpio=12-17=a2
gpio=20-25=a2
dtoverlay=dpi24
enable_dpi_lcd=1
display_default_lcd=1
extra_transpose_buffer=2
dpi_group=2
dpi_mode=87
dpi_output_format=0x7f216
dpi_timings=720 0 46 2 42 720 0 16 2 18 0 0 0 60 0 60000000 6
dtoverlay=waveshare-4dpic-3b-4b
dtoverlay=waveshare-4dpic-3b
dtoverlay=waveshare-4dpic-4b

#Note: For Raspberry Pi 4, you need to comment out dtoverlay=vc4-fkms-V3D.
```

Download the ****[**4inch DPI LCD \(C\) DTBO file**](https://www.waveshare.com/w/upload/0/03/4DPIC_DTBO.zip)**s** and extract them_._ There will be 3 .dtbo files.

```bash
$ mkdir -p -- Downloads # creates download folder, if it doesn't exist
$ cd Downloads
$ wget https://www.waveshare.com/w/upload/0/03/4DPIC_DTBO.zip
$ unzip 4DPIC_DTBO.zip
$ ls

# OURTPUT:
# $ waveshare-4dpic-3b.dtbo
# $ waveshare-4dpic-3b-4b.dtbo
# $ waveshare-4dpic-4b.dtbo
```

Copy the above three files to the overlays directory `/boot/overlays/`

```bash
# if your extraction directory doesn't have any other .dtbo files, 
# you can simply do the following:

$ cp *.dtbo /boot/overlays/
```

To rotate the display,  edit: `/boot/config.txt`:

```bash
$ sudo nano /boot/config.txt
```

Add the following:

```bash
display_rotate=1 #1：90；2: 180； 3: 270
```

Finally:

```bash
sudo reboot
```



