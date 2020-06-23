#!/bin/bash
# Small little install script, so you can run the bgps command globally without doing the heavy lifting by hand
# will need sudo, be sure you read it before you run it, for safety.

# global flags
silent=1
readme=1
uninstall=1
helponly=0

# global variables
curr=$(pwd) # current directory to return to
dir="/usr/local/bin" # default directory to place symlink

# styling
bold=$(tput bold) 
funky=$(tput setaf 6; tput setab 0) # set styling for WOW factor
nofunky=$(tput sgr0) # clear styling

# look at flags for script
POSITIONAL=()
while [[ $# -gt 0 ]]; do
	flag="$1"
	case $flag in
        -h|--help)
            helponly=1
            shift $# # past all other args
            ;;
		-d|--directory)
			dir="$2"
			shift # past argument
			shift # past value
			;;
		-s|--silent)
			silent=0
			shift # past argument
			shift # past value
			;;
		-r|--readme)
			readme=0
			shift # past argument
			shift # past value
			;;
		-u|--uninstall)
			uninstall=0
            shift $# # past all other args
			;;
		*) # unknown argument
            helponly=1
			POSITIONAL+=("$1")
			shift # past argument
			;;
	esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -z dir ]]; then
	dir="/usr/local/bin"
fi # reset to default if they tryna be smart

function silent_install {
	cd $dir # relocating to the proper place for custom scripts...
	sudo ln -s $curr"/bgps.sh" bgps # create symlink so you can use bgps as a command
	cd $curr # move to original directory
}

function noisy_install {
	echo $funky # add styling
	cd $dir # relocating to the proper place for custom scripts...
	echo "Moving to /usr/local/bin/ to place symlink..."
	sudo ln -s $curr"/bgps.sh" bgps # create symlink so you can use bgps as a command
	echo "Symlink created..."
	cd $curr # going back home...
	echo "Moving back to original directory..."
	echo "All done! You can now run the command \bgps\ at will from anywhere."
	echo $nofunky # remove styling
}

function viewreadme {
	echo "Opening README.md for viewing..."
	sleep 3 # so I'm not super rude, moving you without warning
	more README.md # so you aren't hit with a FULL wall of text
}

function viewhelptext {
    echo $bold
    echo $funky # add styling
    printf "\n%s\n\t\t%s\n\n" "Flags and Arguments - sudo ./install.sh [-h] [-r] [-d <directory>] [-u]" "NOTE: All flags are optional." 
    echo $nofunky # remove styling

    printf "\t%s\n\t%s\n\t%s\n\t%s\n\t%s\n\n\n" "-h|--help) Presents this help text, prevents any other flags from being read." "-s|--silent) Run install silently, no output to terminal." "-r|--readme) View README.md after the install is complete, with a pause before the file opens." "-d|--directory) Set a new directory to place the symlink. Not recommended unless required." "-u|--uninstall) Uninstall, removing the symlink. Does not self-delete files."

}

# install options logic
if [ $helponly -eq 1 ]; then
    # show help text only
    viewhelptext                            
elif [ $uninstall -eq 0 ]; then
	# uninstall
	cd $dir # goto where symlink is
	sudo rm bgps # remove it
	cd $curr # return to directory
else
	# silent v. noisy
	if [ $silent -eq 0 ]; then
		silent_install
	else
		noisy_install
	fi
	# readme
	if [ $readme -eq 0 ]; then
		viewreadme
	fi
fi
