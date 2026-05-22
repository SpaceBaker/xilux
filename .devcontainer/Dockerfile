###################################################################
# Build stage                                                     #
# This step might use packages not needed in the final image      #
###################################################################
FROM ubuntu:noble AS build

# Prevent interactive prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

# Install tools and dependancies
RUN apt update --fix-missing \
    && apt upgrade -y \
    && apt install -y --no-install-recommends \
        autoconf \
        bc \
        bison \
        build-essential \
        ca-certificates \
        coccinelle \
        cmake \
        device-tree-compiler\
        dfu-util \
        efitools \
        flex \
        gdisk \
        git \
        graphviz \
        imagemagick \
        libgnutls28-dev \
        libguestfs-tools \
        libncurses-dev \
        libpython3-dev \
        libsdl2-dev \
        libssl-dev \
        lz4 \
        lzma \
        lzma-alone \
        mtd-utils \
        openssl \
        perl \
        pkg-config \
        python3 \
        python3-asteval \
        python3-coverage \
        python3-filelock \
        python3-pkg-resources \
        python3-pycryptodome \
        python3-pyelftools \
        python3-pytest \
        python3-pytest-xdist \
        python3-sphinxcontrib.apidoc \
        python3-sphinx-rtd-theme \
        python3-subunit \
        python3-testtools \
        python3-venv \
        swig \
        u-boot-tools \
        uuid-dev \
        wget \
        xxd

# Install toolchain arm-gnu-toolchain-15.2.rel1 (hardfloat) for x86_64
ARG TOOLC_NAME=arm-gnu-toolchain
ARG TOOLC_VER=15.2.rel1
ARG HOST_ARCH=x86_64
ARG TARGET=arm-none-linux-gnueabihf
ARG TOOLCHAIN=${TOOLC_NAME}-${TOOLC_VER}-${HOST_ARCH}-${TARGET}
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu/${TOOLC_VER}/binrel/${TOOLCHAIN}.tar.xz \
    && tar -xJf ${TOOLCHAIN}.tar.xz -C /opt/ \
    && rm ${TOOLCHAIN}.tar.xz \
    && ln -s /opt/${TOOLCHAIN}/bin/* /usr/local/bin/

# Install bootgen
ARG BOOTGEN_VER=xilinx_v2025.1
RUN wget https://github.com/Xilinx/bootgen/archive/refs/tags/${BOOTGEN_VER}.tar.gz \
    && tar -xzf ${BOOTGEN_VER}.tar.gz \
    && rm ${BOOTGEN_VER}.tar.gz \
    && make -C bootgen-${BOOTGEN_VER} -j$(nproc) \
    && install -m 755  bootgen-${BOOTGEN_VER}/build/bin/bootgen -D /usr/local/bin/bootgen \
    && rm -rf bootgen-${BOOTGEN_VER}

# Remove unnecessaryu packages and metadata
RUN apt autoremove -y \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*


###################################################################
# Final stage                                                     #
# This step will resize the final image with the appropriate size #
###################################################################
FROM build AS final

ARG TARGET=arm-none-linux-gnueabihf

# Remove ubuntu user, free up the UID/GID 1000
RUN userdel -r ubuntu

# Setting Toolchain's environement variable
ENV ARCH="arm" \
    CHOST="${TARGET}" \
    CROSS_COMPILE="${TARGET}-" \
    CC="${TARGET}-gcc" \
    CXX="${TARGET}-g++" \
    CPP="${TARGET}-gcc -E" \
    AR="${TARGET}-ar" \
    AS="${TARGET}-as" \
    LD="${TARGET}-ld" \
    RANLIB="${TARGET}-ranlib"

WORKDIR /workspace