# rootfs

This is the filesystem of your whole system where, as a user, you can interact with directly.  
It is the userspace.

## Deploying the rootfs on an SD card

### Staging BusyBox

See `busybox.md` for more information about configuring and building BusyBox.

`CONFIG_PREFIX="<path/to/rootfs_staging>" make install`  
note: The default install dir is \<path/to/busybox>/_install

Alternatively

`make install`  
`cp <path/to/busybox>/_install/* <path/to/rootfs_staging>`

### Staging Kernel modules

See `kernel.md` for more information about configuring and building the Kernel and its modules.

#### Built-in

The built-in modules are the one provided in the Linux kernel source code.

`INSTALL_MOD_PATH="${TOP_DIR}/rootfs_staging" make modules_install`  
This will install all modules and related files to the rootfs staging directory.

#### External

These modules are the ones normally found in the 'modules' directory of this project.

Based on the `hello-kernel` example, the only command needed is the following :

`make install`

The destination of the install is hardcoded in the makefile :

```Makefile
install:
    $(MAKE) -C ${KERNEL_DIR} M=$(PWD) INSTALL_MOD_PATH="${TOP_DIR}/rootfs_staging" INSTALL_MOD_DIR="test" modules_install
```

### Staging the apps

The userspace apps can be installed virtually anywhere.  
However, they are commonly found in :

* /bin
* /usr/bin
* /usr/local/bin
* /opt/\<app_name\>/bin
* /home/\<user\>/.local/bin

`cp <path/to/app>/bin/app <path/to/rootfs_staging>/usr/local/bin`

### Staging the libraries

Dynamically linked binaries need to load libraries into their code at runtime.  
This reduce the size of each binary by eliminating redundant code.

To find all the libraries needed for your system, run the following script :

`libdep.sh -d <path/to/rootfs_staging>`

This will create a .libdep file with a list of all the dependancies.

Find the dependancies (in your toolchain sysroot) and transfer them in the rootfs staging directory.  
For example :

`cp ${CROSS_COMPILER_SYSROOT}/lib/ld-linux-armhf.so.3 <path/to/rootfs_staging>/lib`

### Init script

TODO

### Transfer to SD card

`sudo cp <path/to/rootfs_staging>/* /mnt/<rootfs/mount/path>`

The rootfs should now be ready to be used.
