#!/bin/bash

case $1 in 
	1)
	echo "Equilateral"
	;;

	2)
	echo "Isosceles"
	;;

	3)
	echo "Scalene"
	;;

	*)
	echo "Not a triangle"
	;;
esac