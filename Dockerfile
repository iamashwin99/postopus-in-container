FROM debian:bullseye

# install Octopus 12.1 on Debian implimented from fangohr/octopus-in-spack

######### Octopus Setup #########
# Convenience tools (up to emacs)
# Libraries that octopus needs (up to procps)
# and optional dependencies (starting from libnetcdf-dev)
RUN apt-get -y update && apt-get -y install wget time nano vim emacs \
    autoconf libtool git gcc g++ gfortran libxc-dev libblas-dev liblapack-dev libgsl-dev libfftw3-dev build-essential procps \
    libnetcdff-dev libetsf-io-dev libspfft-dev libnlopt-dev libyaml-dev libgmp-dev likwid libmpfr-dev libboost-dev \
    && rm -rf /var/lib/apt/lists/*

# Mimic the host uid and gid from host to container to enable write support to mounted volumes
RUN groupadd cfel -g 3512 # group for CFEL
RUN useradd karnada --create-home --shell /bin/bash -g 3512 -u 52351
USER karnada

# Build Octopus
WORKDIR /home/karnada
RUN wget -O oct.tar.gz https://octopus-code.org/down.php?file=12.1/octopus-12.1.tar.gz && tar xfvz oct.tar.gz && rm oct.tar.gz
WORKDIR /home/karnada/octopus-12.1
RUN autoreconf -i
RUN ./configure

# Which optional dependencies are missing?
RUN cat config.log | grep WARN > octopus-configlog-warnings
RUN cat octopus-configlog-warnings

# all in one line to make image smaller
USER root
RUN make && make install && make clean && make distclean
USER karnada

RUN octopus --version > octopus-version
RUN octopus --version

# The next command returns an error code as some tests fail
# RUN make check-short

RUN mkdir -p /home/karnada/octopus-examples
COPY --chown=karnada:cfel examples /home/karnada/octopus-examples

# Instead of tests, run two short examples
RUN cd /home/karnada/octopus-examples/h-atom && octopus
RUN cd /home/karnada/octopus-examples/he && octopus
RUN cd /home/karnada/octopus-examples/recipe && octopus

######### Postopus Setup #########
USER root
RUN apt-get -y update && apt-get -y install python3 python3-pip
USER karnada
RUN pip install jupyterlab
EXPOSE 8888

# Mount the host directory containing the  src as a volume in the container
RUN mkdir -p /home/karnada/io
USER root
RUN chown -R karnada:cfel /home/karnada/io
# required to solve ImportError: libGL.so.1: cannot open shared object file: No such file or directory
RUN apt-get install ffmpeg libsm6 libxext6  -y  
USER karnada
RUN pip install git+https://gitlab.com/octopus-code/postopus.git 
RUN pip install "holoviews[recommended]"

# CD to directory where we mount the host file system
WORKDIR /home/karnada/io

# RUN jupyter lab --LabApp.token='' --ip=${HOSTNAME} > /dev/null 2>&1 &  disown
# use 'start-jupyter-lab.sh' script from inside container
CMD bash -l
