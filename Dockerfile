############################################################
# Dockerfile to build RNNLIB container image
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu:15.04

# File Author / Maintainer
MAINTAINER Scott Gigante

# In order to access GCC 4.4, add the following repos to apt-get
#RUN echo "deb http://us.archive.ubuntu.com/ubuntu vivid main universe" >> /etc/apt/sources.list

# Update the repository sources list
RUN apt-get update

# Install system packages
RUN apt-get install -y wget bzip2 make

################## BEGIN INSTALLATION ######################
# Install RNNLIB following the following instructions
# Ref: http://kosklain.github.io/how-to-install-rnnlib.html

# Set working directory
WORKDIR /usr/local/src/

# Install NetCDF
RUN apt-get install -y libnetcdf-dev netcdf-bin

# Install Boost 1.46
WORKDIR /usr/local/src/
RUN wget http://downloads.sourceforge.net/project/boost/boost/1.46.0/boost_1_46_0.tar.gz
RUN tar -xzf boost_1_46_0.tar.gz

# Install python and required packages for data manipulation
RUN apt-get install -y python-pip libfreetype6-dev
RUN apt-get install -y python-scipy
RUN pip install matplotlib nco
# pip install scientificpython
RUN wget https://github.com/scottgigante/rnnlib/raw/master/ScientificPython-2.8.1.tar.gz
RUN tar -xzf ScientificPython-2.8.1.tar.gz
WORKDIR /usr/local/src/ScientificPython-2.8.1
RUN python setup.py build
RUN python setup.py install
WORKDIR /usr/local/src

# Modify GCC and G++ to the version 4.4
RUN apt-get install -y gcc-4.4
RUN apt-get install -y g++-4.4
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.4 50
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.4 50

# Download RNNLIB
RUN wget http://downloads.sourceforge.net/project/rnnl/rnnlib.tar.gz
RUN tar -xzf rnnlib.tar.gz

# Replace line 344 of Helpers.hpp
WORKDIR /usr/local/src/rnnlib_source_forge_version
RUN sed -i '344s/template <class R> static integer_range<typename boost::range_size<R>::type> indices(const R\& r)/template <class R> static integer_range<typename boost::range_difference<R>::type> indices(const R\& r)/' src/Helpers.hpp

# Install
RUN CXXFLAGS=-I/usr/local/src/boost_1_46_0 ./configure
RUN make
RUN make install

##################### INSTALLATION END #####################

# Set default container command
ENV PYTHONPATH /usr/local/src/rnnlib_source_forge_version/utils
WORKDIR /usr/local/src
ENTRYPOINT /bin/bash
