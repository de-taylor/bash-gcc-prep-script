
#!/bin/bash
# BASH GCC Compiler Prep
# Simplifies the compilation of large C and C++ projects without using a clunky IDE by automatically finding and adding your header
# files and their .c bodies to your gcc command. Yippee!
# Created by Dallas Taylor (TheOnyxheart) under a GPL license, you can distribute, modify, or copy at your own peril.
# v0.1 - 01/2019

# global flags
compflag=0 # whether or not to compile, 0=true, 1=false
runflag=1 # whether or not to run the program after compiling, 0=true, 1=false, default to no

# styling variables
errortext=$(tput setaf 1; tput setab 0)
actiontext=$(tput setaf 6; tput setab 0)
cleartext=$(tput sgr0)

# get flags and flag values from script call
while getopts :f:c:o:r option; do  # f is for the file with the main function in it, c is getting the compiler type gcc/g++
	case $option in
		f) filename=$OPTARG;; # name of c/c++ file to work on
		c) compiler=$OPTARG;; # what type of compiler, gcc/g++
		o) outputfile=$OPTARG;; # what the output file should be called, default to filename
		r) runflag=0;; # yes, run file upon successful compilation
		?) echo $errortext"$OPTARG is not a recognized option for this script."$cleartext && compflag=1;;
	esac
done

# default command options
if [[ -z $compiler ]]; then
	compiler="gcc" # defaulting to C programs
fi
if [[ -z $outputfile ]]; then
	outputfile=$(echo $filename | awk -F "." '{print $1}') # ignore extension
fi

# compiler options
if [[ $compiler == "g++" ]]; then
	cstd="c++14"
else
	cstd="c11"
fi

# array to hold files to compile, starting with original filename
compfiles=("$filename")


# auxiliary functions for program
function scanfile {
	# finds all instances of headers, should then sort them one by one into an array
	sf_out=$(cat $filename | grep '#include "' | awk -F '"' '{print $2}' | awk -F "." '{print $1}')

	while IFS=' ' read -ra hdr_arr; do
		for hdr in "${hdr_arr[@]}"; do
			echo $hdr >> tempfile.txt
		done
	done <<< "$sf_out"
}

# check to make sure main product file exists
if [[ ! -f $filename ]]; then
	echo $errortext"ERROR: "$cleartext"That file doesn't exist"
	compflag=1
else
	scanfile
fi

if [ $compflag -eq 1 ]; then
	echo $errortext"Aborting compilation..."$cleartext
else
	while read hdrf; do
		if [[ ! -f "$hdrf.h" ]]; then
			echo $errortext"ERROR: "$cleartext"$hdrf.h doesn't exist, compilation can't continue."
			compflag=1 # cannot continue, flag will terminate compilation
			break
		else
			echo $actiontext"Adding $hdrf.h and $hdrf.c to compilation command..."$cleartext
			compfiles+=("$hdrf.h") && compfiles+=("$hdrf.c") # need to add header and implementation
		fi
	done < tempfile.txt
	# remove temporary file storage after adding to internal array
	sudo rm tempfile.txt
fi

files=""

for hdr in "${compfiles[@]}"; do
	files+="$hdr "
done

# build command
compcmd=$($compiler -O -g -Wall -std=$cstd $files -o "$outputfile")
echo $actiontext"Executing command: $compiler -O -g -Wall -std=$cstd $files-o $outputfile"$cleartext

# execute compilation
if $compcmd ; then
	if [ $runflag -eq 0 ]; then
		echo
		echo $actiontext"================================ Running $outputfile... ===================================="$cleartext
		echo
		./$outputfile # run newly compiled program
	fi
fi
