#!/bin/bash

# check if --remove flag is active. Default mode is install.
case "$1" in
	"-r" | "--remove")
		mode="remove"
		;;
	"")
		##set the default mode to install
		mode="install"
		;;
	"-i" | "--install")
		mode="install"
		;;
	*)
		echo "Wrong argument '$1'"
		echo "Usage;"
		echo "-i or --install for installing packages. The default mode is install."
		echo "-r or --remove for removing packges."
		exit 1
		;;
esac

# Detecting package manager.
DetectPM() {
	#PACMAN support
	if command -v pacman >/dev/null 2>&1; then
		packageManager="pacman"

		if [[ "$mode" == "remove" ]]; then
			## list installed packages installed on local machine.
			listCommand="pacman -Qq"
			## -Rns removes the package with its dependencies.
			operationCommand="sudo pacman -Rns"
		else
			##list pacman repository
			listCommand="pacman -Ssq"
			operationCommand="sudo pacman -S"
		fi

	#APT support
	elif command -v apt >/dev/null 2>&1; then
		packageManager="apt"

		if [[ "$mode" == "remove" ]]; then
			##list only installed programs.
			listCommand="dpkg --get-selections | grep -w install | awk '{print \$1'"
			operationCommand="sudo apt remove"
		else
			listCommand="apt-cache pkgnames"
			operationCommand="sudo apt install"
		fi

	#DNF support
	elif command -v dnf >/dev/null 2>&1; then
		packageManager="dnf"
		if [[ "$mode" == "remove" ]]; then
			listCommand="dnf -q list installed | tail -n +2 | awk '{print \$1'"
			operationCommand="sudo dnf remove"
		else
			listCommand="dnf -q list available | tail -n +2 | awk '{print \$1'"
			operationCommand="sudo dnf install"
		fi

	#ZYPPER suppport
	elif command -v zypper >/dev/null 2>&1; then
		packageManager="zypper"
		if [[ "$mode" == "remove" ]]; then
			listCommand="zypper -q search -i | tail -n +5 | awk -F'|' '{print \$2' | tr -d ' '"
			operationCommand="sudo zypper remove"
		else
			listCommand="zypper -q search | tail -n +5 | awk -F'|' '{print \$2' | tr -d ' '"
			operationCommand="sudo zypper install"
		fi

	#Exit if no package manager found.
	else
		echo "No supported package manager found."
		exit 1
	fi
}

CheckFzf() {
	#Check if fzf is installed.
	if !command -v fzf >/dev/null 2>&1; then
		echo "fzf is not installed."
		
		#ask to user if they want to install fzf.
		read -p "Do you want to install fzf using $packageManager? (y/N): " fzfAns
		
		if [[ "$fzfAns" == "y" || "$fzfAns" == "Y" ]]; then
			echo "installing fzf..."
			eval "$operationCommand fzf"

			#check if fzf installation complete
			if !command -v fzf >/dev/null 2>&1; then
				echo "fzf installation failed. Please re-run the script or install it manually."
				exit 1
			else
				echo "fzf installation complete."
			fi
		else
			echo "Can not run the script without fzf. Exiting."
			exit 1
		fi
	fi
}

#Main Program
DetectPM
CheckFzf

prompt=$(tr '[:lower:]' '[:upper:]' <<< ${mode:0:1})${mode:1}

selectedPackages=$(eval "$listCommand" | fzf -m --prompt="$prompt ($packageManager)> ")

if [[ -n "$selectedPackages" ]]; then
	#list packages side by side
	packages=$(echo "$selectedPackages" | tr '\n' ' ')
	echo "$packages will be $mode d."
	eval "$operationCommand $packages"
else
	#if the user find what they were looking for they will be prompted to use either yay or paru if an aur helper is installed.
	if [[ "$mode" == "install" ]] && [[ "$packageManager" == "pacman" ]]; then
		if command -v yay >/dev/null 2>&1; then
			aurHelper="yay"
		elif command -v paru >/dev/null 2>&1; then
			aurHelper="paru"
		else
			echo "No aur helper found. Exiting."
			exit 0
		fi

		read -p "$packages not found in the pacman repo. Do you wish to search them using $aurHelper? (y/N): " aurAns
		if [[ "$aurAns" == "y" ]] || "$aurAns" == "Y" ]]; then
			echo "Listing AUR packages."
			aurSelected=$(eval "$aurHelper -Slq" | fzf -m --prompt="AUR")

			if [[ -n "$aurSelected" ]]; then
				aurPackages=$(echo "$aurSelected" | tr '\n' ' ')
				echo "$packages will be installed using $aurHelper."
				eval "$aurHelper -S $packages"
			else
				echo "No package selected. Exiting."
			fi
		else
			echo "Install failed."
		fi
	else
		echo "No package selected. Exiting."
	fi
fi

