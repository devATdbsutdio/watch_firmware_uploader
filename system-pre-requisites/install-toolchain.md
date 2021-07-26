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



