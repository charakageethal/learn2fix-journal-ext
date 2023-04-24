FROM ubuntu:18.04

RUN apt-get -y update

RUN apt-get -y install git wget build-essential time zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev

RUN wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz

RUN tar -xf Python-3.7.2.tar.xz

RUN cd Python-3.7.2 && ./configure --enable-optimizations && make -j4 && make altinstall

RUN ln -s $(which pip3.7) /usr/bin/pip

RUN ln -s $(which python3.7) /usr/bin/python

#install numpy

RUN apt-get -y update

RUN pip install --upgrade pip

# install scikit-learn

RUN pip install -U scikit-learn


# install Learn2fix-interactive

RUN cd /root &&  git clone https://github.com/charakageethal/learn2fix-journal-ext.git

WORKDIR /root/learn2fix-journal-ext

