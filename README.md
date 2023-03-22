# learn2fix-journal-ext
## Step 1- Install Supporting Components
Use the followng commands to Python3.7, numpy (https://numpy.org/) and scikit-learn (https://scikit-learn.org/stable/)
```
apt-get update
apt-get -y install git wget build-essential time zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev

#Install Python 3.7
pushd /tmp
wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz
tar -xf Python-3.7.2.tar.xz
cd Python-3.7.2
./configure --enable-optimizations
make -j4
make altinstall
ln -s $(which pip3.7) /usr/bin/pip
mv /usr/bin/python /usr/bin/python.old
ln -s $(which python3.7) /usr/bin/python
popd

# install numpy
pip install numpy

# install scikit-learn
pip install -U scikit-learn
```
## Step 2- Install LEARN2FIX
Clone the repository
```
git clone https://github.com/charakageethal/learn2fix-journal-ext.git
```
## Step 3- Running the interactive interface
This repository contains a sample bechmark as <b>triangle_bench</b>. To run the interactive interface use the following command
```
python Learn2Fix_DCT_interactive.py -s triangle_bench/1-T-bug-steve-triangle -l <<no of max labels>> -d
```
