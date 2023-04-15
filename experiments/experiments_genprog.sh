#!/bin/bash

if [ $# -ne 2 ]; then
  echo "$0 <reults.csv file> <test suite: manual / autogen>" 1>&2
  exit
fi

if ! [ -f "$1" ]; then
  echo "Not a file: $2" 1>&2
  exit
fi

results_csv=$1
test_suite=$2

if ! [[ $test_suite == "manual" || $test_suite == "autogen" ]]; then
  echo "Valid test suite type: manual / autogen" 1>&2
  exit
fi

if [ -z "$(which cilly)" ]; then
  echo "cilly compiler not found!" 1>&2
  exit
fi

codeflaws_dir="/root/codeflaws"
repair_dir="/root/repair_dir"

if ! [ -e "$codeflaws_dir" ]; then
  echo "Copy the codeflaws directory to /root" 1>&2
fi

if ! [ -e "$repair_dir" ]; then
  mkdir $repair_dir
fi

cp repairs/genprog/* $repair_dir/

if [ -e $repair_dir/genprog-run ]; then
  echo "[INFO] Saving $repair_dir/genprog-run.." 1>&2
  rm -rf $repair_dir/genprog-run.old 2> /dev/null
  mv $repair_dir/genprog-run $repair_dir/genprog-run.old
fi
mkdir $repair_dir/genprog-run

if [ -e $repair_dir/genprog-allfixes ]; then
  echo "[INFO] Saving $repair_dir/genprog-allfixes.." 1>&2
  rm -rf $repair_dir/genprog-allfixes.old 2> /dev/null
  mv $repair_dir/genprog-allfixes $repair_dir/genprog-allfixes.old
fi
mkdir $repair_dir/genprog-allfixes

for s in $(ls -1d $codeflaws_dir/*/); do
  subject=$(echo $s | rev | cut -d/ -f2 | rev)
  contestnum=$(echo $subject | cut -d$'-' -f1)
  probnum=$(echo $subject | cut -d$'-' -f2)
  buggyfile=$(echo $subject | cut -d$'-' -f4)
  goldenfile=$(echo $subject | cut -d$'-' -f5)

  cp repairs/genprog/test-genprog-incal.py $s/


  for i in $(seq 1 $(nproc --all)); do
  (
    if [ 1 -eq $(cat $results_csv | grep "$subject,$i," | wc -l) ]; then
      autotest=$(cat $results_csv | grep "$subject,$i,")
      autogen=$($repair_dir/run-version-genprog.sh $subject $i $test_suite 10m)
      echo $autotest | tr -d '\n'
      echo ,$autogen
    fi

  ) >> results_it_$i.csv & 
  done
  wait

done



