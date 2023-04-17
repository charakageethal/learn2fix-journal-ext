# learn2fix-journal-ext
[Learn2Fix](https://github.com/mboehme/learn2fix) is a human-in-the-loop Automatic Program Repair (APR) technique for programs taking numeric inputs. In this journal extension, Learn2Fix is tested with different classification algorithms, in addition to [INCAL](https://github.com/ML-KULeuven/incal), and one more automated program repair tool, [Angelix](https://github.com/mechtaev/angelix). Also, the impact of incorrectly labelled test on oracle learning and APR is tested as well. Moreover, we have created an interactive user interface that works with the *steve error* in the [triangle classification problem](https://russcon.org/triangle_classification.html).  

Learn2Fix is tested with the following classification algorithm in machine learning. 
1) INCAL (Incremental SMT Constraint Learner)
2) Decision Tree 
3) AdaBoost
4) Support Vector Machines 
5) Na&iuml;ve Bayes
6) Neural networks (Two configurations)

We use GenProg([Paper](https://ieeexplore.ieee.org/document/6035728),[Tool](https://github.com/squareslab/genprog-code)) and Angelix([Paper](https://discovery.ucl.ac.uk/id/eprint/10088929/1/icse16.pdf),[Tool](https://github.com/mechtaev/angelix)) for the APR experiments. Similar to our previous version, we use C programs from Codeflaws([Paper](https://codeflaws.github.io/postercameraready.pdf),[Tool](https://codeflaws.github.io/)).  

We conducted our experiments in Ubutu 18.04.6 LTS with 32 logical cores.

# Getting started

## <a id="install_comp"/> Step 1- Install Supporting Components
Use the followng commands to Python3.7, [numpy](https://numpy.org/) and [scikit-learn](https://scikit-learn.org/stable/) 
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
Installing [INCAL](https://github.com/ML-KULeuven/incal)

```bash
git clone https://github.com/ML-KULeuven/incal.git
cd incal
# install Latte
wget https://github.com/latte-int/latte/releases/download/version_1_7_5/latte-integrale-1.7.5.tar.gz
tar -xvzf latte-integrale-1.7.5.tar.gz
cd latte-integrale-1.7.5
./configure
make -j4
make install

cd ..
python setup.py build
python setup.py install
pip install cvxopt
pip install plotting
pip install seaborn
pip install wmipa
pip install pywmi
pysmt-install --z3 #confirm with [Y]es

# Export environment variables
export PATH=$PATH:$PWD/latte-integrale-1.7.5/dest/bin/
export PYTHONPATH=$PWD/incal/experiments
export PYTHONPATH=$PYTHONPATH:$PWD/incal/extras
export PYTHONPATH=$PYTHONPATH:$PWD/incal
```
## Step 2- Install Codeflaws

```bash
git clone https://github.com/codeflaws/codeflaws
cd codeflaws/all-script
wget http://www.comp.nus.edu.sg/~release/codeflaws/codeflaws.tar.gz
tar -zxf codeflaws.tar.gz
```

## Step 3- Install LEARN2FIX
Clone the repository
```
git clone https://github.com/charakageethal/learn2fix-journal-ext.git
```

# <a id="oracle_learning"/> Running oracle learning experiments
To run the experiments of oracle learning with Decision Tree, AdaBoost, Support Vector Machines,  Na&iuml;ve Bayes and Neural networks setups, use the following commands. 

```bash
cd learn2fix-journal-ext/experiments
./experiments_other_classifiers.sh <<path to codeflaws directory>> <<classification algorithm>>
```
Use the following terms in `<<classification algorithm>>` to specify the classification algorithms
  * Decision Tree : DCT
  * AdaBoost : ADB
  * Support Vector Machines : SVM
  * Na&iuml;ve Bayes : NB
  * MLP(20): MLP-20
  * MLP(20,5): MLP-20-5
  
To run the experiments with INCAL, copy the `learn2fix-journal-ext/experiments/experiments_INCAL.sh` and `learn2fix-journal-ext/experiments/Learn2Fix_INCAL.py` to `incal/notebooks`. Then use the following command

```bash
./experiments_INCAL.sh <<path to codeflaws directory>>
```
Under each run of an algorithm, Learn2fix generates a repair test suite, i.e., an auto-generated repair test suite. To use the auto-generated test suites in further experiments, **create a copy of the codeflaws directory after completing the experiment of a classification algorithm**. e.g.

```bash
cp codeflaws codeflaws_<<classification algorithm>>_repair
```

Each experiment produces several .csv files, one for each experimental run (e.g. results_it_1.csv for the first run). At the end of the experiment, concatenate all .csv files to create a single file containing all results.

```bash
cat results_it_*.csv > results_<<classification algorithm>>.csv
# Use the previous naming conventions e.g.: for decision tree, results_DCT.csv
```

After completing all the algorithms, use `results/RScript_and_CSV/classifier_vs_oracle/Plot_learn2fix_all_classifiers.R` to produce the plots. The results that we obtained in the experiments are in `results/RScript_and_CSV/classifier_vs_oracle`.

# Running repair test suite coverage experiments

For the copy of Codeflaws saved under each classification algorithm in the [previous step](#oracle_learning), run the following script to obtain the coverage of the auto-generated repair test suites.
```
./experiments_repair_test_suite_coverage.sh <<codeflaws directory>> autogen
```
To obtain the coverage of the manual, heldout and heldout-golden run the following script under any copy of Codeflaws directory.
```bash
./experiments_repair_test_suite_coverage.sh <<codeflaws directory>> manual # Manual repair test suites
./experiments_repair_test_suite_coverage.sh <<codeflaws directory>> heldout # Heldout test suites
./experiments_repair_test_suite_coverage.sh <<codeflaws directory>> heldout-golden $ Heldout test suites on golden versions
```
Each experiment generates a set of csv files, one for each run. At the end of an experiment, concatenate all .csv files to create a single file containing all results.
```bash
cat results_it_*.csv > <<test_suite_name>>_cov.csv
```
After completing all the experiments, use `learn2fix-journal-ext/results/RScript_and_CSV/coverage_repair_test_suites/cov_compare_all.R` to generate the plots. Our results coverage experiments are available at `learn2fix-journal-ext/results/RScript_and_CSV/coverage_repair_test_suites/`. 

# Running the interactive interface
This repository contains a sample bechmark as <b>triangle_bench</b>. To run the interactive interface use the following command
```
cd learn2fix-journal-ext/user-interface
python Learn2Fix_DCT_interactive.py -s triangle_bench/1-T-bug-steve-triangle -l <<no of max labels>> -d
```
