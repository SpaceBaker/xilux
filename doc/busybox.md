# busybox

## What is busybox

> BusyBox combines tiny versions of many common UNIX utilities into a single small executable.  
> It provides replacements for most of the utilities you usually find in GNU fileutils, shellutils, etc.
>
> The utilities in BusyBox generally have fewer options than their full-featured GNU cousins;  
> however, the options that are included provide the expected functionality and behave very much like their GNU counterparts.  
> BusyBox provides a fairly complete environment for any small or embedded system.
>
> BusyBox has been written with size-optimization and limited resources in mind.  
> It is also extremely modular so you can easily include or exclude commands (or features) at compile time.  
> This makes it easy to customize your embedded systems. To create a working system, just add some device nodes in /dev, a few configuration files in /etc, and a Linux kernel.
>
> BusyBox is maintained by Denys Vlasenko, and licensed under the GNU GENERAL PUBLIC LICENSE version 2.
>

source: <https://www.busybox.net/about.html>

## Download

### Git

`git clone --depth 1 --branch <remote-tag/branch> https://github.com/mirror/busybox.git`

### Tarball

You can simply download the source code of the desired version and extract it.

## Configuration

Make sure to source the `setup_env.sh` script before working with busybox.  
This sets your work environment to the correct target/architecture.
clea
`make defconfig`

`make menuconfig`

`make`

`make install`  
Default install dir is \<path/to/busybox>/_install

`cp \<path/to/busybox/src>/_install/* ${TOP_DIR}/rootfs_staging`  
This is the rootfs that will be running on the target system.
