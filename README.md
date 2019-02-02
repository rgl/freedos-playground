My FreeDOS playground.

# Usage

Install [Packer](https://www.packer.io/).

**NB** FreeDOS/DOS is not a multi-task system, so it does not
really have a ssh/telnet server which could be used by packer.
so when you build this, packer will never succeed, but you
will be able to create the disk image.

## qemu-kvm usage

Install qemu-kvm:

```bash
apt-get install -y qemu-kvm
apt-get install -y sysfsutils
systool -m kvm_intel -v
```

Type `make build-libvirt`.

When the VM shutdowns, save the disk image:

```bash
mv output-freedos-1.2-libvirt/packer-freedos-1.2-libvirt freedos-1.2-libvirt.img.orig
cp freedos-1.2-libvirt.img{.orig,}
```

Then manually kill qemu.

Then manually start the VM:

```bash
qemu-system-i386 \
    -name freedos-1.2 \
    -machine type=pc,accel=kvm \
    -m 32 \
    -smp 1 \
    -display sdl \
    -serial telnet:127.0.0.1:4444,server,nowait \
    -net nic,model=pcnet \
    -net user \
    -drive file=freedos-1.2-libvirt.img,if=ide,format=qcow2 \
    -boot c
```

Try some commands:

```batch
ver
mem /c
mem /full
c:\mtcp\htget -o rmenu-17.zip http://www.bttr-software.de/products/jhoffmann/rmenu-17.zip
unzip -l rmenu-17.zip
rem "help" will not really work when used from the serial port.
help
```

## Console redirection to the Serial port

You can partially redirect the screen/keyboard to the serial port:

```batch
ctty com1
```

**BUT** bear in mind that the serial port will be bypassed when the application (e.g. `edit`, `fdisk`, etc.) directly writes to the screen.

Then, on the host, use `telnet` to access it:

```batch
telnet localhost 4444
```

You can use the following command to redirect back to the console:

```batch
ctty con
```

# Packer boot_command

As FreeDOS does not have any way to be pre-seeded, this environment has to answer all the
installer questions through the packer `boot_command` interface. This is quite fragile, so
be aware when you change anything. The following table describes the current steps and
corresponding answers.

| step                                                                                                                      | boot_command                                          |
|--------------------------------------------------------------------------------------------------------------------------:|-------------------------------------------------------|
| select `Install to harddisk` and wait for boot                                                                            | `i<enter><wait10>`                                    |
| answer `What is your preferred language?` with `English`                                                                  | `<enter><wait>`                                       |
| answer `Do you want to proceed?` with `Yes - Continue with the installation`                                              | `<enter><wait>`                                       |
| answer `Do you want to partition your drive?` with `Yes - Partition drive C:`                                             | `<up><enter><wait>`                                   |
| answer `Do you want to use large disk (FAT32) support (Y/N)?`                                                             | `Y<enter><wait>`                                      |
| select `1. Create DOS partition or Logical DOS Drive`                                                                     | `1<enter><wait>`                                      |
| select `1. Create Primary DOS Partition`                                                                                  | `1<enter><wait>`                                      |
| answer `Do you wish to use the maximum available size for a Primary DOS Partition and make the partition active (Y/N)?`   | `Y<enter><wait>`                                      |
| select `Press Esc to continue`                                                                                            | `<esc><wait>`                                         |
| select `Press Esc to exit FDISK`                                                                                          | `<esc><wait>`                                         |
| select `Press Esc to exit FDISK`                                                                                          | `<esc><wait>`                                         |
| answer `Do you want to reboot now?` with `Yes - Please reboot now`                                                        | `<enter><wait>`                                       |
| wait for reboot to finish                                                                                                 | `<wait10>`                                            |
| select `Install to harddisk` and wait for boot to finish                                                                  | `i<enter><wait10>`                                    |
| answer `What is your preferred language?` with `English`                                                                  | `<enter><wait>`                                       |
| answer `Do you want to proceed?` with `Yes - Continue with the installation`                                              | `<enter><wait>`                                       |
| answer `Do you want to format your drive?` with `Yes - Please erase and format drive C:`                                  | `<up><enter><wait>`                                   |
| wait for the format to finish                                                                                             | `<wait10><wait10><wait10><wait10><wait10><wait10>`    |
| answer `Please select your keyboard layout` with default `US English (Default)`                                           | `<enter><wait>`                                       |
| answer `What FreeDOS packages do you want to install?` with default `Full installation`                                   | `<enter><wait>`                                       |
| answer `Do you want to install now?` with `Yes - Please install FreeDOS 1.2`                                              | `<up><enter><wait>`                                   |
| wait for the install to finish                                                                                            | `<wait10><wait10><wait10><wait10><wait10><wait10>`    |
| wait for the install to finish                                                                                            | `<wait10><wait10><wait10><wait10><wait10><wait10>`    |
| answer `Do you want to reboot now?` with `Yes - Please reboot now`                                                        | `<enter><wait>`                                       |
| wait for reboot to finish                                                                                                 | `<wait10>`                                            |
| select `Boot from harddisk` and wait for boot                                                                             | `h<enter><wait10>`                                    |
| shutdown                                                                                                                  | `shutdown<enter><wait>`                               |

# Reference

* http://freedos.sourceforge.net/wiki/index.php/Networking_FreeDOS_complete
* http://wiki.freedos.org/wiki/index.php/VirtualBox
* http://www.brutman.com/mTCP/
* http://www.easydos.com/ctty.html
* http://help.fdos.org/en/hhstndrd/command/ctty.htm
