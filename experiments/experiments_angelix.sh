#!/bin/bash

if [ $# -ne 2 ]; then
  echo "$0 <reults.csv file> <test suite: manual / autogen>" 1>&2
  exit
fi

if ! [ -f "$1" ]; then
  echo "Not a file: $1" 1>&2
  exit
fi

results_csv=$1
test_suite=$2

if ! [[ $test_suite == "manual" || $test_suite == "autogen" ]]; then
  echo "Valid test suite type: manual / autogen" 1>&2
  exit
fi


rm -rf angelix_call_manual_*
rm -rf angelix_call_autogen_*


codeflaws_dir="/root/codeflaws"

if ! [ -e "$codeflaws_dir" ]; then
  echo "Copy the codeflaws directory to /root" 1>&2
fi

for i in $(seq 1 $(nproc --all)); do
  mkdir angelix_call_${test_suite}_$i
  cp repairs/angelix/codeflaws-defect-detail-info.txt angelix_call_${test_suite}_$i
  cp repairs/angelix/versions-ignored-all.txt angelix_call_${test_suite}_$i
  cp repairs/angelix/run-version-angelix.sh angelix_call_${test_suite}_$i
done

for s in $(ls -1d $codeflaws_dir/*/); do
  subject=$(echo $s | rev | cut -d/ -f2 | rev) 
  cp repiars/angelix/test-angelix-autogen.sh $s
  contestnum=$(echo $subject | cut -d$'-' -f1)
  probnum=$(echo $subject | cut -d$'-' -f2)
  buggyfile=$(echo $subject | cut -d$'-' -f4)
  goldenfile=$(echo $subject | cut -d$'-' -f5)

  sed -i "s/bug_prog/$contestnum-$probnum-$buggyfile/g"   $s/test-angelix-autogen.sh
  sed -i "s/gold_prog/$contestnum-$probnum-$goldenfile/g" $s/test-angelix-autogen.sh
  chmod +x $s/test-angelix-autogen.sh


  for i in $(seq 1 $(nproc --all)); do
  (
      if [ 1 -eq $(cat $1 | grep "$subject,$i," | wc -l) ]; then
            autotest=$(cat $1 | grep "$subject,$i,")
            angelixout=$(timeout 20m ./angelix_call_${test_suite}_$i/run-version-angelix.sh $subject $i ${test_suite} | grep "learn2fixout:*" | cut -d':' -f 2)

            if [ "$angelixout" == "" ]; then
                    angelixout="${test_suite},TIMEOUT,0,,,"
            fi
            echo $autotest | tr -d '\n'
            echo ,$angelixout

      fi

  ) >> results_it_$i.csv & 
  done
  wait


  pkill klee
  pkill z3
  pkill angelix
  pkill gcc
  pkill python3
  pkill $contestnum-$probnum-$buggyfile
  pkill $contestnum-$probnum-$goldenfile

done


