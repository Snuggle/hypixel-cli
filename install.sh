#!/bin/bash
printf "Starting hypixel-cli installation script! 🐱\n"
installationDirs="/usr/local/bin /usr/bin"

printf "Checking dependencies...\n\n" # Check that the jq JSON processor is installed...
testJSON="{\"foo\": \"bar\"}" 		  # Using some random test JSON data.
JSONOutput=$(jq -r ".foo" <<<"$testJSON")

if [ "$JSONOutput" == "bar" ]; then
	printf "\e[38;5;28m✔️\e[39m | jq appears to be installed!\n" #😎
else
	# Give installation instructions! ❤
	printf "\e[38;5;203m❌\e[39m| jq isn't installed? Please install it using your package manager!\n"
	if [[ $OSTYPE == linux-gnu ]]; then 
		printf "🐧| Try \"sudo apt get install jq\", \"sudo pacman -S jq\" or something similar for your Linux distribution.\n"
	elif [[ $OSTYPE == darwin* ]]; then
		printf "🍎| Try \"brew install jq\" if you have Homebrew installed! (Or see https://brew.sh if you don't.)\n"
	else
		printf "❓| Please visit https://stedolan.github.io/jq/download/ for download instructions!\n"
	fi
	exit 1 # Cannot continue without the power of JSON. ):
fi

printf "\nAll dependencies found! 🎉\n\n" # Make sure the user knows wtf is happening! D:
printf "Installing...\n"

# Copy script to /usr/bin/local or /usr/bin
for directory in $installationDirs; do
	if [ -d $directory ]; then
		printf "\e[39mCopying main script to \"$directory/hypixel\".\n\e[38;5;203m"
		cp -f "./hypixel.sh" "$directory/hypixel"
		break
	fi
done

# Copy JSON etc. to ~/.config
directory=~/.config
if [ -d $directory ]; then # If ~/.config doesn't exist?
	directory=~/.config/hypixel-cli
	if [ ! -d $directory ]; then # If ~/.config/hypixel-cli doesn't exist; create it.
		printf "\e[39mCreating \"$directory\".\n"
		mkdir "$directory"
	fi

	# Actually copy files now.
	printf "\e[39mCopying JSON files to \"$directory/*.json\".\n\e[38;5;203m"
	cp -f "./ranks.json" "$directory/ranks.json"
else
	printf "Could not find ~/.config at $directory. Aborting.\n"
	exit 1 # Cannot continue if the user doesn't have ~/.config. ):
fi

printf "\e[39m\nInstallation should be complete!\nIf you see any red error messages, you might need to run this installation script as root/with sudo.\nHope you enjoy! c:\n\nMade by:\n"
hypixel player Snuggle # Shameless credits. ;)