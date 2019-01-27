# bash-gcc-prep-script

## Purpose: To simplify my C/C++ project compilation without the overhead of an IDE on Linux machines

## Syntax: bgps -f filename.c/cpp [-c gcc/g++] [-o outputfilename] [-r]

## Flags

- -f - indicate the filename of the C/C++ project file with the main() function
	- this is where the script will look for headers/implementation files to add to the script
	- for .h files, the script tries to find both a .h and a .c file to the compilation command
	- FUTURE FEATURE: be able to differentiate between .h and .c files included
		- for .c, the script will just add that one file
- -c - [optional] - indicate the compiler to use, gcc or g++
	- FUTURE FEATURE: auto-detect the project type and assign a compiler dynamically
- -o - [optional] - indicate the name of the compiled executable
	- defaults to filename from -f, and drops the file extension
- -r - [optional] - indicate whether or not the script should run the new executable after compilation

## WIP

- nothing, for now

## Versioning

- v1.0 - Original release, first working script
	- Came with the -f, -c, -o, and -r flags
	- Auto-selected the -std= to run based on compiler
		- gcc - -std=c11
		- g++ - -std=c++14
	- Defaulted to gcc compiler if none specified
		- Will be replaced with a dynamic compiler selector based on file type
	- Scans main project file (-f argument) for programmer-created files ONLY
		- Will scan ALL programmer-created files that are included in the main file for additional headers
		- But uh, rule of thumb, just #include your header files in the main project file for simplicity... and place them in the order needed.
	- Error checking for whether the files actually exist
		- will not attempt to compile otherwise
	- Makes use of a tempfile.txt for holding headers until I find a way to pass data back from a BASH function
		- it then makes an array from that file, and THEN makes a string from that array at the very end... from the original string... wait...
	- Optionally can run the program after compilation automatically, emulating how IDEs can build/run. Kinda.
