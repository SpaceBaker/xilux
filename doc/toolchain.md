# toolchain

## In depth

### What is cross-compiling

Cross compiling simply refers to compiling code that will run on a machine with a  
different architecture than the one that compiled the code.

▶ build machine, where the build takes place  
▶ host machine, where the compiling takes place (often the same as the build machine)  
▶ target machine, where the compiled code will run

Ample documentation is available online.  
[crosstool-NG](https://crosstool-ng.github.io/docs/) is a good starting point.

### Difference between toolchain and SDK

A toolchain is just the compiler, binutils and C library

An SDK is a toolchain, plus a (potentially large) number of libraries built for the target  
architecture, and additional native tools helpful when building software.  
It allows application developers to build application/libraries for the target.

### Toolchain tuple

A system definition describes a system: CPU architecture, operating system, vendor, ABI, C library.

#### Forms

&emsp;▶ \<arch>-\<vendor>-\<os>-\<libc/abi>, full form  
&emsp;▶ \<arch>-\<os>-\<libc/abi>

#### Components

&emsp;▶ \<arch>, the CPU architecture: arm, aarch64, mips, powerpc, i386, i686, etc.  
&emsp;▶ \<vendor>, (mostly) free-form string, ignored by autoconf  
&emsp;▶ \<os>, the operating system, often none or linux.  
&emsp;▶ \<libc/abi>, combination of details on the C library and the ABI in use

### Bare-metal vs. Linux toolchain

#### 'none' for bare-metal toolchains

&emsp;▶ Used for development without an operating system  
&emsp;▶ C library used is generally newlib  
&emsp;▶ Provides C library services that do not require an operating system  
&emsp;▶ Allows to provide basic system calls for specific hardware targets  
&emsp;▶ Can be used to build bootloaders or the Linux kernel, cannot build Linux userspace code

#### 'linux' for Linux toolchains

&emsp;▶ Used for development with a Linux operating system  
&emsp;▶ Choice of Linux-specific C libraries: glibc, uclibc, musl  
&emsp;▶ Supports Linux system calls  
&emsp;▶ Can be used to build Linux userspace code, but also bare-metal code such as  
&emsp;&emsp;bootloaders or the kernel itself

### Components of a Linux toolchain

There are four core components in a Linux cross-compilation toolchain :

&emsp;▶ binutils  
&emsp;▶ gcc  
&emsp;▶ Linux kernel headers  
&emsp;▶ C library

#### BINUTILS

Provide the following tools:

&emsp;▶ ld (linker)  
&emsp;▶ as (assembler)  
&emsp;▶ addr2line  
&emsp;▶ ar (archiver)  
&emsp;▶ c++filt  
&emsp;▶ gold (newer linker)  
&emsp;▶ gprof  
&emsp;▶ nm  
&emsp;▶ objcopy  
&emsp;▶ objdump  
&emsp;▶ ranlib  
&emsp;▶ readelf  
&emsp;▶ size  
&emsp;▶ strings  
&emsp;▶ strip

#### GCC

The GNU Compiler Collection  
Provides the following:

&emsp;▶ cc1 (the C compiler), only generate assembly code in text format  
&emsp;▶ cc1plus (C++ compiler), only generate assembly code in text format  
&emsp;▶ gcc, C compiler drivers which drives the compiler itself but also binutils' as and ar.  
&emsp;▶ g++, C++ compiler drivers which drives the compiler itself but also binutils' as and ar.  
&emsp;▶ libgcc (gcc runtime)  
&emsp;▶ libstdc++ (the C++ library)  
&emsp;▶ Headers files for the standard C++ library  
&emsp;▶ Other libraries if your toolchain contains other languages, like fortran

#### Linux Kernel Headers

In order to build a C library, the Linux kernel headers are needed. It defines the system call numbers,  
various structure types and definitions.

In the kernel, headers are split between:

&emsp;▶ User-space visible headers, stored in uapi directories:  
&emsp;&emsp;▶ include/uapi/  
&emsp;&emsp;▶ arch/\<ARCH>/include/uapi/asm  
&emsp;▶ Internal kernel headers

The kernel to userspace ABI is backward compatible.  
Therefore, the version of the kernel used for the kernel headers must be the same version or  
older than the kernel version running on the target system.  
Otherwise the C library might use system calls that are not provided by the kernel.

#### C library

Provides the implementation of the POSIX standard functions, plus several other standards and extensions.  
Based on the Linux system calls.  
After compilation and installation, it provides:

&emsp;▶ The dynamic linker ld.so  
&emsp;▶ The C library itself (libc.so)  
&emsp;▶ Companion libraries (libm, librt, libpthread, libutil, libnsl, libresolv, libcrypt)  
&emsp;▶ The C library headers (stdio.h, string.h, etc.)

### Sysroot

The sysroot is the the logical root directory for headers and libraries.  
It is where gcc looks for headers, and ld looks for libraries.

The location can be overriden at runtime when using gcc's `--sysroot` option.  
The current sysroot can be printed using the -print-sysroot option.

The kernel headers and the C library are installed in `SYSROOT`.

### Toolchain contents

```sh
\<arch>-\<vendor>-\<os>-\<libc/abi>/  
├── \<arch>-\<vendor>-\<os>-\<libc/abi>  
├── bin  
├── include  
├── lib  
├── libexec  
└── share
```

#### \<arch>-\<vendor>-\<os>-\<libc/abi>/

```sh
arm-none-linux-musleabihf/  
├── bin/                    : Limited set of binutils programs, without their cross-compilation prefix.  
├── include/  
│   └── c++/  
│       └── \<gcc-version>/ : Headers for the C++ standard library, installed by gcc... not part of the sysroot per-se.  
├── lib/                    : The gcc runtime libraries, built for the target  
│   ├── libatomic.so        : provides a software implementation of atomic built-ins  
│   ├── libgcc.so           : the main gcc runtime  
│   ├── libitm.so           : transactional memory library  
│   ├── libstdc++.so        : standard C++ library  
│   └── libsupc++           : subset of libstdc++ with only the language support functions  
└── sysroot/  
    ├── lib/                : C library and gcc runtime libraries (shared and static)  
    └── usr/  
        ├── bin/  
        ├── include/        : Linux kernel and C library headers  
        ├── lib/            : C library and gcc runtime libraries (shared and static)  
        └── share/
```

#### bin/

Contains `\<arch>-\<vendor>-\<os>-\<libc/abi>-` prefixed tools:

▶ binutils: addr2line, ar, as, elfedit, gcov, gprof, ld, nm, objcopy, objdump, ranlib, readelf, size, strings, strip  
▶ gcc: gcc/cc, g++/c++, cpp, gcc-ar, gcc-nm, gc-ranlib  
&emsp;The gcc-{ar,nm,ranlib} are wrappers for the corresponding binutils program, to support Link Time Optimization (LTO)

#### include/

Contains headers of the host libraires (gmp, mpfr, mpc)

#### lib/

▶ gcc/\<arch>-\<vendor>-\<os>-\<libc/abi>/\<gcc-version>/  
&emsp;▶ crtbegin*.o, crtend*.o, object files handling constructors/destructors, linked into executables  
&emsp;▶ include/, headers provided by the compiler (stdarg.h, stdint.h, stdatomic.h, etc.)  
&emsp;▶ include-fixed/, system headers that gcc fixed up using fixincludes  
&emsp;▶ install-tools/, also related to the fixincludes process  
&emsp;▶ libgcc.a, libgcc_eh.a, libgcov.a, static variants of the gcc runtime libraries

▶ ldscripts/, linker scripts provided by gcc to link programs and libraries  
▶ Host version of gmp, mpfr, mpc, needed for gcc

#### libexec/

▶ cc1, the actual C compiler  
▶ cc1plus, the actual C++ compiler  
▶ collect2, program from gcc collecting initialization functions, wrapping the linker  
▶ install-tools/, misc gcc related tools, not needed for the compilation process  
▶ liblto_plugin.so.0.0.0, lto-wrapper, lto1, related to LTO support

#### share

▶ documentation (man pages and info pages)  
▶ translation files for gcc and binutils

## Installation

Two installation method are available.

1. Pre-built cross-compiler : Easy but not tailor made. Available through vendors or distro packages  
2. Build your own : Complicated but cutomizable. Tools are availabe to make the process easier.

### Pre-built

Use this method to quickly get a working cross-compiler saving yourself from an headache.

However, you will definitely not get the newest tools.

#### Through your distro package manager

If using a Linux system, your distro package manager might already have one readily available.

For exemple, with Ubuntu, you can install a cross-compiler targeting a hard-float arm for gLibC/Linux by entering the following cmd :  
`sudo apt install gcc-arm-linux-gnueabihf`

#### Through vendor

Vendors sometimes provide their own pre-built toolchain.  
You will need to search their website for such download link and install it.

As an exemple, for arm you can find GNU toolchains at [https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)

### Build your own

You can build your own toolchain, but the process is complex and won't be explained here.  
Fortunately, tools are available that makes it simpler. Notably, buildroot and crosstool-NG.  
The Xilux project uses crosstool-NG.

#### crosstool-NG

To build a toolchain using crosstool-NG, follow the following steps :

1. Download released version of crosstool-NG  
`git clone https://github.com/crosstool-ng/crosstool-ng` and checkout the desired version.  
or  
`wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-xxx.xxx.xxx.tar.xz` and extract.  
2. Configure your desired toolchain (this is the complex step, refer to crosstool-NG doc for help)  
`\<path/to/crosstool-ng>/bin/ct-ng menuconfig`  
3. Build the toolchain  
`\<path/to/crosstool-ng>/bin/ct-ng build`  
4. Add the toolchain to your PATH  
`PATH=\<path/to/your/toolchain>/bin:$PATH`

The toolchain is now built and can be used.
