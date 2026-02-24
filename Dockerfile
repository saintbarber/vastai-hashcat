############################
# Stage 1 — Builder
############################
FROM nvidia/cuda:12.8.1-devel-ubuntu22.04 AS builder

ENV HASHCAT_VERSION=v7.1.1
ENV HASHCAT_UTILS_VERSION=v1.9
ENV HCXTOOLS_VERSION=6.3.5
ENV HCXDUMPTOOL_VERSION=6.3.5
ENV HCXKEYS_VERSION=master

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    make \
    build-essential \
    wget \
    pkg-config \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
    libpcap-dev \
    pciutils \
    ocl-icd-libopencl1 \
    clinfo \
    && rm -rf /var/lib/apt/lists/*

RUN update-pciids

WORKDIR /build

# ---- Hashcat ----
RUN git clone https://github.com/hashcat/hashcat.git && \
    cd hashcat && \
    git checkout ${HASHCAT_VERSION} && \
    make -j$(nproc) && \
    make install DESTDIR=/opt/hashcat

# ---- Hashcat Utils ----
RUN git clone https://github.com/hashcat/hashcat-utils.git && \
    cd hashcat-utils/src && \
    git checkout ${HASHCAT_UTILS_VERSION} && \
    make

# ---- hcxtools ----
RUN git clone https://github.com/ZerBea/hcxtools.git && \
    cd hcxtools && \
    git checkout ${HCXTOOLS_VERSION} && \
    make install DESTDIR=/opt/hcxtools

# ---- hcxdumptool ----
RUN git clone https://github.com/ZerBea/hcxdumptool.git && \
    cd hcxdumptool && \
    git checkout ${HCXDUMPTOOL_VERSION} && \
    make install DESTDIR=/opt/hcxdumptool

# ---- kwprocessor ----
RUN git clone https://github.com/hashcat/kwprocessor.git && \
    cd kwprocessor && \
    git checkout ${HCXKEYS_VERSION} && \
    make


############################
# Stage 2 — Runtime (SMALL)
############################
FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04

LABEL com.nvidia.volumes.needed="nvidia_driver"

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

RUN apt-get update && apt-get install -y --no-install-recommends \
    ocl-icd-libopencl1 \
    clinfo \
    pciutils \
    7zip \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Copy only compiled binaries
COPY --from=builder /opt/hashcat/ /
COPY --from=builder /opt/hcxtools/ /
COPY --from=builder /opt/hcxdumptool/ /
COPY --from=builder /build/hashcat-utils/src/cap2hccapx.bin /usr/bin/cap2hccapx
COPY --from=builder /build/kwprocessor/kwp /usr/bin/kwp

WORKDIR /root

ADD wordlists wordlists
ADD rules rules

COPY entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]