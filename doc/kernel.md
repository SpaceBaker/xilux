# The Linux Kernel

The name is self explanatory.  
You can directly 'git clone' linux mainline (or a fork) to this directory (makes it a submodule).  
Or download the tarball as-is.

## Downloading

### Git

#### Method 1

`git submodule add --depth 1 --branch <remote-tag/branch> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git`

`cd kernel && git checkout -b <your-new-branch-name> <remote-tag/branch>`

#### Method 2

`git submodule add --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git kernel`  
'--depth 1' means we won't download the whole history. Only the latest branch is fetched and checked out.

`git config -f .gitmodules submodule.kernel.shallow true`  
This command tells submodule update to only do a shallow update (not really necessary if checking out a tag)

`cd kernel && git fetch origin tag <remote-tag> --no-tags`  
This command fetch only the specified tag

`git checkout -b <your-new-branch-name> <remote-tag/branch>`  
Create a new branch from the specified tag

### Tarball

You can simply download the source code of the desired version and extract it under the 'kernel' folder.

`wget <linux-kernel-version.tar.gz> && tar -xzf <linux-kernel-version.tar.gz> kernel`

## Building

Prior to building anything, source the `setup_env.sh` script. This make sure you are compiling for the correct target.

In the kernel dir, use `make menuconfig` to enable/disable all the neccessary config points you need. This is a complex and tedious task.  
For my specific case, I used the `xilinx_zynq_defconfig` found on Xilinx `linux-xlnx` repo.

(Careful here, it might be trying to change unkown config points)

To find available defconfigs

`make help | grep defconfig`

To create a .config out of a defconfig

`make xxx_defconfig`

To build the kernel (with the maximum available cores)

`make -j$(nproc)`
