# The Linux Kernel

From RedHat :

> The Linux® kernel is the main component of a Linux operating system (OS) and is the core interface between a computer’s hardware and its processes.  
> It communicates between the 2, managing resources as efficiently as possible.  
> The kernel is so named because—like a seed inside a hard shell—it exists within the OS and controls all the major functions of the hardware,  
> whether it’s a phone, laptop, server, or any other kind of computer.
>
> The kernel has 4 jobs:
>
>     1. Memory management: Keep track of how much memory is used to store what, and where  
>     2. Process management: Determine which processes can use the central processing unit (CPU), when, and for how long  
>     3. Device drivers: Act as mediator/interpreter between the hardware and processes  
>     4. System calls and security: Receive requests for service from the processes
>
> The kernel, if implemented properly, is invisible to the user, working in its own little world known as kernel space,  
> where it allocates memory and keeps track of where everything is stored.  
> What the user sees—like web browsers and files—are known as the user space.  
> These applications interact with the kernel through a system call interface (SCI).
>

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

## Configuring the Kernel

Make sure to source the `setup_env.sh` script before working with the Kernel.  
This sets your work environment to the correct target/architecture.

In the kernel dir, use `make menuconfig` to enable/disable all the neccessary config points you need. This is a complex and tedious task.  
Which is why default configurations (defconfig) exist. They are presets of configuration aimed at specific board and maintained by vendors.
For my specific case, I used the `xilinx_zynq_defconfig` found in Xilinx' `linux-xlnx` repo.

### Kconfig

Configuration symbols are defined in files known as Kconfig files.  
Each Kconfig file can describe an arbitrary number of symbols and can also include (source) other Kconfig files.  
Compilation targets that construct configuration menus of kernel compile options, such as make menuconfig,  
read these files to build the tree-like structure.  
Every directory in the kernel has one Kconfig that includes the Kconfig files of its subdirectories.

On top of the kernel source code directory, there is a Kconfig file that is the root of the options tree.  
The menuconfig (scripts/kconfig/mconf), gconfig (scripts/kconfig/gconf) and other compile targets invoke programs that start  
at this root Kconfig and recursively read the Kconfig files located in each subdirectory to build their menus.  
Which subdirectory to visit also is defined in each Kconfig file and also depends on the config symbol values chosen by the user.

### .config

All config symbol values are saved in a special file called .config. Every time you want to change a kernel compile configuration,  
you execute a make target, such as menuconfig or xconfig. These read the Kconfig files to create the menus and update the config symbols'  
values using the values defined in the .config file.  
Additionally, these tools update the .config file with the new options you chose and also can generate one if it didn't exist before.

Because the .config file is plain text, you also can change it without needing any specialized tool. It is very convenient for saving and  
restoring previous kernel compilation configurations as well.

### defconfig

The defconfig files only specify options with non-default values (i.e. options we changed for our board).  
This way we can keep it small and clear. And, since every new kernel version brings a bunch of new options,  
it is not necessary to update the defconfig file for every Kernel releases.

If an option is not mentionned in a defconfig, the value used in the .config is the default value specified in the Kconfig.

Also, it should be mentioned that kernel build system keeps very specific order of options in defconfig file,  
so it's better to avoid modifying it by hand. Instead, use make savedefconfig rule to create a new defconfig.

### Useful commands

`make ARCH=<arch> <your_board_defconfig>`  
This command apply the specified defconfig (with specified arch e.g. 'arm') to your working config (.config).

`make ARCH=<arch> help | grep defconfig`  
This commande lists available defconfig for the specified arch.

`scripts/diffconfig .config_old .config_new`  
This command show the difference between two configs

`make -j$(nproc)`  
To build the kernel (with the maximum available cores)
