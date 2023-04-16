# learn2fix-journal-ext
[Learn2Fix](https://github.com/mboehme/learn2fix) is a human-in-the-loop Automatic Program Repair (APR) technique for programs taking numeric inputs. In this journal extension, Learn2Fix is tested with different classification algorithms, in addition to [INCAL](https://github.com/ML-KULeuven/incal), and one more automated program repair tool, [Angelix](https://github.com/mechtaev/angelix). Also, the impact of incorrectly labelled test on oracle learning and APR is tested as well. Moreover, we have created an interactive user interface that works with the *steve error* in the [triangle classification problem](https://russcon.org/triangle_classification.html).  

Learn2Fix is tested with the following classification algorithm in machine learning. 
1) INCAL (Incremental SMT Constraint Learner)
2) Decision Tree 
3) AdaBoost
4) Support Vector Machines 
5) Na&iuml;ve Bayes
6) Neural networks (Two configurations)

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
