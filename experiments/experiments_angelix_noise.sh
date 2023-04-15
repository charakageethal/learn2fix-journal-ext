!/bin/bash

if [ $# -ne 1 ]; then
  echo "$0 <reults.csv file>" 1>&2
  exit
fi

if ! [ -f "$1" ]; then
  echo "Not a file: $1" 1>&2
  exit
fi

results_csv=$1


rm -rf angelix_call_autogen_*


codeflaws_dir="/root/codeflaws"

if ! [ -e "$codeflaws_dir" ]; then
  echo "Copy the codeflaws directory to /root" 1>&2
fi

for i in $(seq 1 $(nproc --all)); do
  mkdir angelix_call_autogen_$i
  cp repairs/angelix_noise/codeflaws-defect-detail-info.txt angelix_call_autogen_$i
  cp repairs/angelix_noise/versions-ignored-all.txt angelix_call_autogen_$i
  cp repairs/angelix_noise/run-version-angelix.sh angelix_call_autogen_$i
done

for s in $(ls -1d $codeflaws_dir/*/); do
  subject=$(echo $s | rev | cut -d/ -f2 | rev) 
  cp repiars/angelix_noise/test-angelix-autogen-noise.sh $s
  contestnum=$(echo $subject | cut -d$'-' -f1)
  probnum=$(echo $subject | cut -d$'-' -f2)
  buggyfile=$(echo $subject | cut -d$'-' -f4)
  goldenfile=$(echo $subject | cut -d$'-' -f5)

  sed -i "s/bug_prog/$contestnum-$probnum-$buggyfile/g"   $s/test-angelix-autogen-noise.sh
  
  chmod +x $s/test-angelix-autogen-noise.sh


  for i in $(seq 1 $(nproc --all)); do
  (
      if [ 1 -eq $(cat $1 | grep "$subject,$i," | wc -l) ]; then
            autotest=$(cat $1 | grep "$subject,$i,")
            angelixout=$(timeout 20m ./angelix_call_${test_suite}_$i/run-version-angelix.sh $subject $i autogen | grep "learn2fixout:*" | cut -d':' -f 2)

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


