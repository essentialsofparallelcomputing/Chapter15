FROM ubuntu:18.04 AS builder
WORKDIR /project
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update && \
    apt-get -qq install -y cmake git vim gcc g++ gfortran software-properties-common \
            mpich libmpich-dev \
            openmpi-bin openmpi-doc libopenmpi-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installing latest GCC compiler (version 10)
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get -qq update && \
    apt-get -qq install -y gcc-10 g++-10 gfortran-10 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# We are installing both OpenMPI and MPICH. We could use the update alternatives to switch between them
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 90\
                        --slave /usr/bin/g++ g++ /usr/bin/g++-10\
                        --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-10\
                        --slave /usr/bin/gcov gcov /usr/bin/gcov-10

SHELL ["/bin/bash", "-c"]

RUN groupadd chapter15 && useradd -m -s /bin/bash -g chapter15 chapter15

WORKDIR /home/chapter15
RUN chown -R chapter15:chapter15 /home/chapter15
USER chapter15

RUN git clone --recursive https://github.com/essentialsofparallelcomputing/Chapter15.git

WORKDIR /home/chapter15/Chapter15
#RUN make

ENTRYPOINT ["bash"]