#!/bin/bash
BUGGEXEFILE=bug_prog
GOLDENEXEFILE=gold_prog
ANGELIXPRE=$ANGELIX_RUN

rm -R BUGG* &> /dev/null
rm -R GOLDEN* &> /dev/null

if ! `which time` -o time.out  -f "(%es)" timeout -k 50s 50s $ANGELIXPRE ./$BUGGEXEFILE < $1 | sed -e '/^$/d' -e 's/^[ \t]*//' > BUGG$1; then
	exit 2
else
	if grep "Command" time.out; then
		exit -1
	fi

	if ! `which time` -o time.out  -f "(%es)" timeout -k 50s 50s ./$GOLDENEXEFILE < $1 | sed -e '/^$/d' -e 's/^[ \t]*//' > GOLDEN$1; then
		echo "Runtime error" > GOLDEN$1
	else
		if grep "Command" time.out; then
			echo "ERROR" > $GOLDEN$1
		fi

		if diff --brief --ignore-trailing-space BUGG$1 GOLDEN$1; then
			exit 0
		else
			echo "Wrong answer"
			exit 1
		fi

	fi 

fi

exit 1
