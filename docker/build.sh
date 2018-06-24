#!/bin/sh
set -eu pipefail

apt-get update && apt-get install -y --no-install-recommends \
  python \
  python3 \
  git \
  python3-pip \
  python-pip \
  python-dev \
  python3-dev \
  libatlas-base-dev \
  gfortran \
  python3-pandas \
  python-numpy

  pip3 install click

# Install tools
mkdir /build

#Install python 3.6
cd /build
wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tgz
tar xvf Python-3.6.3.tgz
cd Python-3.6.3
./configure --enable-optimizations --with-ensurepip=install
make -j8
make altinstall

# install htslib - required by seqtool
cd /build
wget --quiet -O htslib-1.8.tar.bz2 \
https://github.com/samtools/htslib/releases/download/1.8/htslib-1.8.tar.bz2
tar xfj htslib-1.8.tar.bz2
cd htslib-1.8
./configure
make
make install

# install PyVCF - required by seqtool
cd /build
git clone https://github.com/jamescasbon/PyVCF.git
cd PyVCF
python setup.py install

# install seqtool
cd /build
git clone https://github.com/seandavi/SDST.git
cd SDST
python setup.py install

# install snpSift
cd /build
wget --quiet -O snpEff_v${SNPEFF_VERSION}_core.zip \
    http://downloads.sourceforge.net/project/snpeff/snpEff_v${SNPEFF_VERSION}_core.zip \
  && unzip snpEff_v${SNPEFF_VERSION}_core.zip -d /opt/ \
  && rm snpEff_v${SNPEFF_VERSION}_core.zip