#!/bin/bash
# BASH GCC Prep Script
# Simplifies the compilation of large C and C++ projects without using a clunky IDE by automatically finding and adding your header
# files and their .c bodies to your gcc command. Yippee!
# Created by Dallas Taylor (de-taylor) under a GPL license, you can distribute, modify, or copy at your own peril.
# v1.1 - 01/2019 - Officially released -- and already there's some stuff to fix...

# global flags
compflag=0 # whether or not to compile, 0=true, 1=false
runflag=1 # whether or not to run the program after compiling, 0=true, 1=false, default to no
helponly=0

# global variables
# styling
errortext=$(tput setaf 1; tput setab 0) # red on black background
actiontext=$(tput setaf 6; tput setab 0) # blue on black background
cleartext=$(tput sgr0) # clear styling
# misc

if [[ $1 == "-h" || $1 == "--help" ]]; then
    helponly=1 # set help text without filename as first arg
else
    filename=$1 # should be argument 1 for the script, proceed as normal
fi

# get flags and flag values from script call
POSITIONAL=() # array to hold unknown arguments
while [[ $# -gt 0 ]]; do
	flag="$2"
	 case $flag in
        -h|--help)
            # set help text with filename as first arg
            helponly=1
            shift $# # past all other args
            ;;
		-c|--compiler)
			compiler="$3"
			shift # past argument
			shift # past value
    		;;
		-o|--output)
			outputfile="$3"
			shift # past argument
			shift # past value
			;;
		-r|--run-program)
			runflag=0
			shift # past argument
			shift # past value
			;;
		*) # unknown argument
			POSITIONAL+=("$2") # save in array for later
			shift # past argument
			;;
	esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# if help flag is set, only run it

if [ $helponly -eq 1 ]; then
    # add styling
    echo $actiontext
    echo $(tput bold)

    printf "\n%s\n\n" "Flags and Arguments - bgps <filename>.c|<filename>.cpp [-h] [-c gcc | g++] [-o <output filename>] [-r]"

    echo $cleartext # clears formatting of header

    printf "\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\n\n" "Argument 1 (filename) Give the name of the project file with the main() function." "-h|--help) Show this help text." "-c|--compiler) [Optional] Specify gcc/g++ compiler." "-o|--output) [Optional] Specify name of output file, defaults to main file name." "-r|--run-program) [optional] Choose whether to run the program after compilation."

    exit # end script

fi # end help

# error resistance for filename
while [[ -z $filename ]]; do # if the variable is empty
	# prompt for a filename, this is not optional
	read -p "You must enter a filename: " filename
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
	cstd="c++17"
else
	cstd="c17"
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
	echo $errortext"ERROR: "$cleartext"$filename doesn't exist"
	compflag=1
else
	scanfile
fi

if [ $compflag -eq 1 ]; then
	echo $errortext"Aborting compilation..."$cleartext
else
	if [[ -f "tempfile.txt" ]]; then # if it doesn't exist, there were no headers included in main project file
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
		rm tempfile.txt
	fi

	# create string to append to command
	files=""
	for hdr in "${compfiles[@]}"; do
		files+="$hdr "
	done

	# build command
	compcmd=$($compiler -O -g -Wall -std=$cstd $files -o "$outputfile")
	echo $actiontext"Executing command: $compiler -O -g -Wall -std=$cstd $files-o $outputfile"$cleartext

	# execute compilation, and run if successful AND the -r flag was selected
	if $compcmd ; then
		if [ $runflag -eq 0 ]; then
			echo
			echo $actiontext"================================ Running $outputfile... ===================================="$cleartext
			echo
			./$outputfile # run newly compiled program
		fi
	fi
fi
