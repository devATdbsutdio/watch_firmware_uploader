---
description: >-
  For installing necessary tools that aid in running our main firmware and also
  to some degree help configure the system a bit
---

# Install toolchain

Clone the project repository and navigate to it

```bash
$ cd $HOME
$ git clone https://github.com/dattasaurabh82/clock_uploader_machine.git
```

If you look into it:

```bash
$ cd clock_uploader_machine && ls -l
# you will see 
-rw-r--r--  1 user  group  edits date and time README.md
-rw-r--r--  1 user  group  edits date and time SUMMARY.md
-rwxr--r--  1 user  group  edits date and time installer_settings.yaml
-rwxr--r--  1 user  group  edits date and time installer.sh
-rwxr--r--  1 user  group  edits date and time programmer.sh
-rwxr--r--  1 user  group  edits date and time programmer_settings.yaml
```

We are interested in these 4 files:

```bash
# setting file for tools installer
installer_settings.yaml
# tool-chain installer script
installer.sh
# settings file for programmer script
programmer_settings.yaml
# programmer script itself
programmer.sh
```

### Installer settings:

```bash
yq e installer_settings.yaml # ** yq yaml parse must be installed for next steps as well.
```

Here you can edit to your needs. 

```bash
BINARY:
    # arduino-cli binary download link
    LINK: https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_ARMv7.tar.gz
    # base dir where /bin/arduino-cli willbe installed
    BASE: /home/pi/test
    CORES: # links for board cores you want to install 
        LINK: # these will be appended in arduino-cli's config file
            - http://drazzy.com/package_drazzy.com_index.json
            - https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
        CORE_NAMES: # names of cores you want to install 
            - megaTinyCore:megaavr # Note I have used full FQBN here
LIBS: # 3rd-party libraries you want to install
    - TinyMegaI2C
    - RV8803Tiny
```

