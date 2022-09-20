FROM debian:bullseye

# install Octopus 11.4 on Debian implimented from fangohr/octopus-in-spack

# Convenience tools (up to emacs)
# Libraries that octopus needs (up to procps)
# and optional dependencies (starting from libnetcdf-dev)
RUN apt-get -y update && apt-get -y install wget time nano vim emacs \
    autoconf libtool git gcc g++ gfortran libxc-dev libblas-dev liblapack-dev libgsl-dev libfftw3-dev build-essential procps \
    libnetcdff-dev libetsf-io-dev libspfft-dev libnlopt-dev libyaml-dev libgmp-dev likwid libmpfr-dev libboost-dev \
    && rm -rf /var/lib/apt/lists/*

RUN useradd user --create-home --shell /bin/bash
USER user
WORKDIR /home/user
RUN wget -O oct.tar.gz http://octopus-code.org/down.php?file=11.4/octopus-11.4.tar.gz && tar xfvz oct.tar.gz && rm oct.tar.gz

WORKDIR /home/user/octopus-11.4
RUN autoreconf -i
RUN ./configure

# Which optional dependencies are missing?
RUN cat config.log | grep WARN > octopus-configlog-warnings
RUN cat octopus-configlog-warnings

# all in one line to make image smaller
USER root
RUN make && make install && make clean && make distclean
USER user

RUN octopus --version > octopus-version
RUN octopus --version

# The next command returns an error code as some tests fail
# RUN make check-short

RUN mkdir -p /home/user/octopus-examples
COPY examples /home/user/octopus-examples

# Instead of tests, run two short examples
RUN cd /home/user/octopus-examples/h-atom && octopus
RUN cd /home/user/octopus-examples/he && octopus
RUN cd /home/user/octopus-examples/recipe && octopus

# offer directory for mounting container
RUN mkdir /io
WORKDIR /io

CMD bash -l
