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

