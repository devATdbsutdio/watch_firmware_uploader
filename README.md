---
description: >-
  Scripts for installing tools and configuring a raspberry pi to make
  assembly-line style mass firmware uploading to Arduino based micros.
---

# Introduction

## Back-story:

So when I work on projects, where typically I would program my Arduino based applications on either the **Arduino IDE**, or in **Visual Studio Code** \( with [Platform IO](https://platformio.org/) setup \) or in **Vim** \( with [arduino-cli](https://arduino.github.io/arduino-cli/latest/) setup \), I would of course use my main machine to do so where everything is configured correctly. I would test the HW under WIP from there as well.

This is good for few boards and continuous testing, while the firmware is under development. But once my firmware is ready and now I want to scale up/upload to multiple same boards and also _use low paid children of the earth_ \[ 🙃 \] to do it for me, I have an assembly line issue, there is no available tooling or system for such.

Well with [arduino-cli](https://arduino.github.io/arduino-cli/latest/) you can solve these issues and many people have been doing so. For purposes like this \([CI/CD](https://arduino.github.io/arduino-cli/latest/configuration/#example_2)\), `arduino-cli` can be [configured](https://arduino.github.io/arduino-cli/latest/configuration/#example_2) and one could use a normal computer or SBC like Raspberry PI, running Linux.

But if you have many systems, you have to do the following first:

1. [Install arduino-cli](https://arduino.github.io/arduino-cli/latest/installation/) on all those or only one such systems.
2. Configure the system with your specific `arduino-cli` build environment parameters like necessary boards info, library info, sketch info in configuration etc.
3. Transfer your firmware to some location on that CD machine \(firmware sounds fancy 🤓,  we would use sketch\)
4. Then some how `ssh` or use `Ansible` or `gRPC` to execute all the previous commands also handle sketch uploads. 

![](.gitbook/assets/exhausting.gif)

The arduino-cli API is awesome and well designed for automation but to install everything on multiple systems is a bit tenuous 😞 and then I thought, while I'm on it, would be also possible to setup the systems with my specific configurations like my boards and my libraries etc.

## Overview:

![](.gitbook/assets/programming_gif%20%281%29.gif)

So I sat down and wrote a shell script, in pure bash \(why? why not?\), with raspberry PI in mind as the SBC for such a host system and this is what it is all about:

1. It will have an installation settings YAML file where one can specify:
2. Where you would like to install the arduino-cli binary on your raspberry pi system.
3. Which boards and HW platforms you want to install.
4. Which libraries \(as needed by your production firmware \).
5. Which firmwares sketch you would like to clone and fetch etc.
6. The installer script will parse the file and do all the magic setup for you with prompts for you watch permit and watch each step with very informative STDOUT.
7. It will also prepare another YAML file with necessary inputs needed, using which one can customise or make their own Continuous Integration Deployment. I will provide an example usage.

