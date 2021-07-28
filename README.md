---
description: README
---

# Introduction

## Scripts for installing tools and configuring a raspberry pi to make assembly-line style mass firmware uploading to Arduino based micros.

## Back-story: 

So when I work on projects, where typically I would program my Arduino based applications on either the **Arduino IDE**, or in **Visual Studio Code** \( with [Platform IO](https://platformio.org/) setup \) or in **Vim** \( with [arduino-cli](https://arduino.github.io/arduino-cli/latest/) setup \), I would of course use my main machine to do so where everything is configured correctly. I would test the HW under WIP from there as well.

This is good for few boards and continuous testing, while the firmware is under development. But once my firmware is ready and now I want to scale up/upload to multiple same boards and also _use low paid children of the earth_ \[ 🙃  \] to do it for me, I have an assembly line issue, there is no available tooling or system for such. 

Well with [arduino-cli](https://arduino.github.io/arduino-cli/latest/) you can solve these issues and many people have been doing so. For purposes like this \([CI/CD](https://arduino.github.io/arduino-cli/latest/configuration/#example_2)\), `arduino-cli` can be [configured](https://arduino.github.io/arduino-cli/latest/configuration/#example_2) and one could use a normal computer or SBC like Raspberry PI, running Linux. 

But if you have many systems, you have to do the following first:

1. [Install arduino-cli](https://arduino.github.io/arduino-cli/latest/installation/) on all those or only one such systems.
2. Configure the system with your specific arduino-cli build environment parameters like necessary boards info, library info, sketch info etc. 
3. Transfer your firmware to some location on that CD machine \(firmware sounds fancy 🤓,  we would use sketch\)
4. Then some how ssh or use Ansible or gRPC to execute all the previous commands also handle sketch uploads. 

The setup sounds a bit exhaustive for such CI/CD pipeline.  🤔

So I sat and wrote down . 

1. A installer script that would install 

