FROM ghcr.io/hdl/debian/bullseye/sim/osvb

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  g++ \
  git \
  make \
  python3-pip \
  time \
 && apt-get autoclean && apt-get clean && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install wheel setuptools \
 && pip3 install doit \
 && mkdir -p /opt/riscv \
 && curl -fsSL https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v14.2.0-3/xpack-riscv-none-elf-gcc-14.2.0-3-linux-x64.tar.gz | \
 tar -xzf - -C /opt/riscv \
 && ls -al /opt/riscv

ENV PATH $PATH:/opt/riscv/xpack-riscv-none-elf-gcc-14.2.0-3/bin
