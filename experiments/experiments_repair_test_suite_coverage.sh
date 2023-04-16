#!/bin/bash

if [ $# -ne 2 ]; then
  echo "$0 <codeflaws directory> <test_suite_type>" 1>&2
  exit
fi
if ! [ -d "$1" ]; then
  echo "Not a directory: $1" 1>&2
  exit
fi

codeflaws_dir=$1
testsuite=$2

rm -rf cov_exp_*

for i in $(seq 1 $(nproc --all)); do
	mkdir cov_exp_$i
	cp Learn2Fix_test_suite_coverage.py cov_exp_$i 
done

for s in $(ls -1d $codeflaws_dir/*/); do
	found=false;
	for f in $(ls -1 $s/*input*); do if [ $(wc -l $f | cut -d" " -f1) -gt 1 ]; then found=true; continue; fi; done;
	if [ "$found" = false ]; then
		if [ $(cat $s/input-neg1 | grep -x -E '[[:blank:]]*([[:digit:]]+[[:blank:]]*)*' | wc -l) -eq 1 ]; then
					subject=$(echo $s | rev | cut -d/ -f2 | rev)
      		buggy=$(echo $subject | cut -d- -f1,2,4)
      		golden=$(echo $subject | cut -d- -f1,2,5)
      		if [ 0 -eq $(grep "$subject" $codeflaws_dir/codeflaws-defect-detail-info.txt | grep "WRONG_ANSWER" | wc -l) ]; then
        		echo "[INFO] Skipping non-semantic bug $subject" 1>&2
        		continue
      		fi

      		for i in $(seq 1 $(nproc --all)); do
      		(
      			cd cov_exp_$i
      			cov_statement=$(timeout 11m python Learn2Fix_test_suite_coverage.py -s $s -t $testsuite -i $i)
      			if [ $? -eq 0 ]; then
      				echo $cov_statement
      			fi
      			cd ..
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