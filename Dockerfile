FROM nvidia/cuda:10.1-devel-ubuntu18.04

# Install required dependencies
RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages libxml2 libopenblas-dev libgflags-dev git build-essential  python3-dev python3-numpy python3-pip wget swig libgtest-dev

# Install MKL
RUN apt-get update && apt-get install -y --force-yes apt-transport-https && \
    wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list' && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install cpio intel-mkl-64bit-2018.3-051 && \
    ln -s -f bash /bin/sh && \
    echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/intel.conf && \
    ldconfig && \
    echo "source /opt/intel/mkl/bin/mklvars.sh intel64" >> /etc/bash.bashrc

RUN update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so  \
    libblas.so-x86_64-linux-gnu      /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so.3  \
    libblas.so.3-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so   \
    liblapack.so-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so.3 \
    liblapack.so.3-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 50 && \
    echo "/opt/intel/lib/intel64"     >  /etc/ld.so.conf.d/mkl.conf && \
    echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/mkl.conf && \
    ldconfig && \
    echo "MKL_THREADING_LAYER=GNU" >> /etc/environment

# Install CMAKE
RUN wget https://github.com/Kitware/CMake/releases/download/v3.21.0-rc3/cmake-3.21.0-rc3-linux-x86_64.tar.gz
RUN mkdir -p /usr/local/cmake && tar -xzf cmake-3.21.0-rc3-linux-x86_64.tar.gz -C /usr/local/cmake
RUN ln -s /usr/local/cmake/cmake-3.21.0-rc3-linux-x86_64/bin/cmake /usr/bin/cmake

# Unpack required sources
RUN cd /usr/src/gtest/ && cmake . && make && cp *.a /usr/lib/
RUN sh -c 'cp /usr/include/cublas*.h /usr/local/cuda/include/'

# Install FAISS
RUN git clone https://github.com/facebookresearch/faiss.git
RUN cd faiss && git checkout v1.6.5 && mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_ARCHITECTURES="30;35;37;50;52;60;61;70;75" && make -j8 && make install

# Install python libraries
RUN pip3 install twine

# Build tsnecuda
ADD ./ /tsnecuda/
WORKDIR /tsnecuda/build

# Build python package
RUN chmod +x ../packaging/build_and_deploy.sh
CMD /bin/bash -c "../packaging/build_and_deploy.sh 10.1"



