#!/bin/bash
BUGGEXEFILE=bug_prog
ANGELIXPRE=$ANGELIX_RUN

rm -R BUGG* &> /dev/null

run_test()
{
test_case="$1"
if ! `which time` -o time.out -f "(%es)" timeout -k 50s 50s $ANGELIXPRE ./$BUGGEXEFILE < $test_case | sed -e '/^$/d' -e 's/^[ \t]*//' > BUGG$test_case; then
echo Sample test \#$test_case: Runtime Error`cat time.out`
echo ========================================
echo Sample Input \#$test_case
        cat $test_case
exit 2
else
if grep "Command" time.out; then 
 echo "ERROR";
 exit -1;
fi
	if diff --brief --ignore-trailing-space BUGG$test_case $2; then
echo Sample test \#$test_case: Accepted`cat time.out`
exit 0
	else
echo Sample test \#$test_case: Wrong Answer`cat time.out`
echo ========================================
 echo Sample Input \#$test_case
 cat $test_case
echo ========================================
echo Sample Output \#$2
cat $2
echo ========================================
echo My Output \#BUGG$test_case
cat BUGG$test_case
echo ========================================
exit 1
fi
    fi
}

test_input=$1
test_output=$(echo ${test_input:0:8}out-${test_input:8:${#test_input}})


run_test "$test_input" "$test_output"

exit 1
