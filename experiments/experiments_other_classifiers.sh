#!/bin/bash
if [ $# -ne 2 ]; then
  echo "$0 <codeflaws directory>" 1>&2
  exit
fi
if ! [ -d "$1" ]; then
  echo "Not a directory: $1" 1>&2
  exit
fi

if [ -z "$2" ]; then
	echo "Specify the classification algorithm" 1>&2
	exit
fi

classification_algorithms=("SVM" "DCT" "NB" "ADB" "MLP-20" "MLP-20-5")

if [[ ! "${classification_algorithms[*]}" =~ "$2"  ]]; then
  echo "Classification algorithm not found" 1>&2
  exit
fi


codeflaws_dir=$1
class_algo=$2

rm $codeflaws_dir/*/autogen* &> /dev/null
rm $codeflaws_dir/*/incal* &> /dev/null


for s in $(ls -1d $codeflaws_dir/*/); do
  found=false;
  for f in $(ls -1 $s/*input*); do if [ $(wc -l $f | cut -d" " -f1) -gt 1 ]; then found=true; continue; fi; done;
  if [ "$found" = false ]; then
    if [ $(cat $s/input-neg1 | grep -x -E '[[:blank:]]*([[:digit:]]+[[:blank:]]*)*' | wc -l) -eq 1 ]; then
      #echo $s
      subject=$(echo $s | rev | cut -d/ -f2 | rev)
      buggy=$(echo $subject | cut -d- -f1,2,4)
      golden=$(echo $subject | cut -d- -f1,2,5)
      if [ 0 -eq $(grep "$subject" $codeflaws_dir/codeflaws-defect-detail-info.txt | grep "WRONG_ANSWER" | wc -l) ]; then
        echo "[INFO] Skipping non-semantic bug $subject" 1>&2
        continue
      fi
      if ! [ -f "$s/$buggy" ]; then
        gcc -fno-optimize-sibling-calls -fno-strict-aliasing -fno-asm -std=c99 -c $s/$buggy.c -o $s/$buggy.o &> /dev/null
        gcc $s/$buggy.o -o $s/$buggy -lm -s -O2 &> /dev/null
      fi
      if ! [ -f "$s/$golden" ]; then
        gcc -fno-optimize-sibling-calls -fno-strict-aliasing -fno-asm -std=c99 -c $s/$golden.c -o $s/$golden.o &> /dev/null
        gcc $s/$golden.o -o $s/$golden -lm -s -O2 &> /dev/null
      fi

      for i in $(seq 1 $(nproc --all)); do
        (
          autotest=$(timeout 11m ./Learn2Fix_other_classifiers.py -t 10 -c "$class_algo" -s $s -i $i)
          if [ $? -eq 0 ]; then
            echo $autotest
          fi
        ) >> results_it_$i.csv &
      done
      wait
    else
      echo "[INFO] Skipping non-numeric input subject: $s" 1>&2
    fi
  else
    echo "[INFO] Skipping multi-line input subject: $s" 1>&2
  fi
done
