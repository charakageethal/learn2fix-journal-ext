import os
import argparse
import subprocess
import glob
import sys

parser=argparse.ArgumentParser()
parser.add_argument("-s","--subject",help="Path to codeflaws bug",required=True)
parser.add_argument("-i","--iteration",help="ID of the current interation", default=1,type=int)
parser.add_argument("-t","--test_suite",help="test suite manual/autogen/heldout/heldout-golden ",required=True)

args=parser.parse_args()

iteration=args.iteration

bug_dir=args.subject.rstrip("/")
temp = bug_dir.split("/")[-1].split("-")
bug_prog = temp[0] + "-" + temp[1] + "-" + temp[3]
gold_prog = temp[0] + "-" + temp[1] + "-" + temp[4]
subject_name = bug_dir.split("/")[-1]

test_suite=args.test_suite

if test_suite not in ["manual", "autogen","heldout","heldout-golden"]:
	sys.exit("[ERROR] invalide test suite. valid types manual/autogen/heldout/heldout-golden")

manual_repair_testsuite=glob.glob(bug_dir+"/"+"input-*",recursive=True)
auto_repair_testsuite=glob.glob(bug_dir+"/"+"autogen-"+str(iteration)+"-*",recursive=True)
heldout_testsuite=glob.glob(bug_dir+"/"+"heldout-*",recursive=True)


if test_suite=="manual":
	prog_name=bug_prog
	filename=bug_dir+"/"+bug_prog
	target_test_suite=manual_repair_testsuite
elif test_suite=="autogen":
	prog_name=bug_prog
	filename=bug_dir+"/"+bug_prog
	target_test_suite=auto_repair_testsuite
elif test_suite=="heldout":
	prog_name=bug_prog
	filename=bug_dir+"/"+bug_prog
	target_test_suite=heldout_testsuite
elif test_suite=="heldout-golden":
	prog_name=gold_prog
	filename=bug_dir+"/"+gold_prog
	target_test_suite=heldout_testsuite

if len(target_test_suite)==0:
	sys.exit("[ERROR]: test suite does not exist")

os.system("cp "+filename+".c .")
os.system("gcc -fprofile-arcs -ftest-coverage -fno-stack-protector " + prog_name+".c -o "+prog_name+" -lm")

for t_repair in target_test_suite:
	os.system("cat "+t_repair+" | ./"+prog_name+" > /dev/null")

cov_results=subprocess.check_output(["gcov",prog_name+".c"], encoding="utf-8")
cov_report_lines=cov_results.split('\n')
cov_line_percentage=cov_report_lines[1]
covered_percentage=float(cov_line_percentage.split(":")[1].split(" ")[0][:-1])/100

os.system("rm "+prog_name+".gcda")
os.system("rm "+prog_name)
os.system("rm "+prog_name+".*")


print(bug_dir.split("/")[-1]+","+str(iteration)+","+str(covered_percentage))