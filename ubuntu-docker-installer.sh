#!/bin/bash

#===============================================================================
# Title:           Ubuntu Docker Installer
# Description:     
#   The "Ubuntu Docker Installer" is a script designed to streamline the 
#   installation of Docker on Ubuntu-based systems. It provides both interactive
#   and automated installation options, ensuring a hassle-free setup process.
#
#   This script checks system compatibility, adds the Docker repository, installs
#   Docker and its dependencies, and configures user permissions. It is ideal for
#   system administrators and developers who need to quickly set up Docker on
#   Ubuntu machines.
# 
# Author:          Zevon T. Flynn
# Date:            10-DEC-2023
# Version:         0.8.8
# Usage:           ./ubuntu-docker-installer.sh
# 
# GitHub Repo:     https://github.com/ztangerineio/vanilla.git
#
# License:         MIT License
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
# 
#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
# 
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#   SOFTWARE.
#===============================================================================


# Declare thy arrays and ye variables
base_essentials=("awk" "apt")
pkg_conflicts=("docker.io" "docker-doc" "docker-compose" "docker-compose-v2" "podman-docker" "containerd" "runc")
required_pkgs=("ca-certificates" "curl" "gnupg")
docker_pkgs=("docker-ce" "docker-ce-cli" "containerd.io" "docker-buildx-plugin" "docker-compose-plugin")

user=$(whoami)
home="/home/$user"
prompt_user=""
sleep_short=$(sleep 0.285)
sleep_medium=$(sleep 0.528)
sleep_long=$(sleep 0.741)

# Function to print text one character at a time with a random delay
incoming_transmission() {

    local text="$1"  # Get the text to print from the first argument
    local min_delay=0.015  # Minimum delay in seconds
    local max_delay=0.05  # Maximum delay in seconds

    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:i:1}"  # Print a single character without newline
        # Generate a random delay within the specified range
        local random_delay=$(awk -v min="$min_delay" -v max="$max_delay" 'BEGIN{srand(); print min+rand()*(max-min)}')
        sleep "$random_delay"  # Wait for the random delay
    done

    echo
}

# Function: Check user's Bash version for compatibility
check_bash_version() {

    incoming_transmission "Checking system requirements, beginning with bourne shell."
    $sleep_medium

    required_major_version=4
    current_version=$(bash --version | head -n1 | awk '{print $4}')
    current_major_version=$(bash --version | head -n1 | awk '{print $4}' | cut -d'.' -f1)

    if (( current_major_version >= required_major_version )); then
        incoming_transmission "Your version of Bash ($current_version) meets this script's requirements. Bashing on!"
        echo
    else
        incoming_transmission "Your version of Bash ($current_version) does not meet this script's minimum requirements. Bash version $required_major_version.0 or greater is required."
        echo
        exit 1
    fi
}

# Function to check for the presence of each package in the base_essentials array
check_base_essentials() {
    for pkg in "${base_essentials[@]}"; do
        if command -v "$pkg" > /dev/null 2>&1; then
            incoming_transmission "Package $pkg is installed."
        else
            incoming_transmission "Package $pkg is not installed. You'll need to install docker manually."
            exit 1
        fi
    done
    echo
}

check_apt_repository() {

    incoming_transmission "Checking for access to package repositories..."
    $sleep_long

    local apt_repository="archive.ubuntu.com"
    local apt_port="80"

    # Timeout for the connection attempt
    local timeout=5

    # Bash's built-in method to check network connectivity
    (echo > /dev/tcp/$apt_repository/$apt_port) &>/dev/null && status=0 || status=1

    # Use the exit status of the above command to determine the outcome
    if [ $status -eq 0 ]; then
        incoming_transmission "APT repository ($apt_repository) is reachable. Let us proceed."
        echo
    else
        incoming_transmission "Unable to reach APT repository ($apt_repository). I am unable to reach the package repositories."
        echo
        exit 1
    fi

}

display_cover() {

    echo
    incoming_transmission "Ahoy, Hologram!"
    echo
    $sleep_medium

    cat << "EOF"
     🌟                            *                    🌠  *  
        *                 ⭐                *            ~      
                ___.                          *          🌟     
       *    ___.\☠️ |.__.           ✨                           
            \__|. .|\_|.                                      
            . X|___|___| .                         ✨           
          .__/_||____ ||__.            *                /\     
  *     .  |/|____ |_\|_ |/ _                          /  \    
        \ _/ |_X__\|_  |\||~,~{                       /    \   
         \/\ |/|    |_ |/:|`X'{                   _ _/      \__
          \ \/ |___ |_\|_.|~~~                   /    . .. . ..
         _|X/\ |___\|_ :| |_.                  - .......... . .
         | __\_:____ |  ||o-|            ___/........ . . .. ..
         |/_-|-_|__ \|_ |/--|       ____/  . . .. . . .. ... . 
 ........:| -|- o-o\_:_\|o-/:....../....................🐚.....
 ._🐳._._._\=\====o==o==o=/:.._._._._._._._🐳_._🌊._._._._._._
 _._._.🌊_._\_\ ._._._._.:._._._🌊._._._._._._._._.🌊_._._._._.
 ._🌊._._._._._._._🌊._._._._._._._._._._🌊_._._._._._._.🌊_._
EOF

    incoming_transmission " .............................................................. "
    incoming_transmission " .... Docker Installation Script for Ubuntu & Bash v4.0^ 🌊.... "
    echo

}

choose_your_path() {

    # Prompt the user for their prefered installation experience
    incoming_transmission "Choose your path...."
    incoming_transmission "1. 🤖 🤝 🧑 Install Docker with prompts. (Interactive installation.)"
    incoming_transmission "2. 🤖 ⚙️  🤷 Install Docker without prompts. (Fully automated installation.)"
    incoming_transmission "3. 🤖 🔫 💥 End program. (Terminate the execution of this script.)"
    echo
    sleep_short

    incoming_transmission "Press 1, 2, or 3 and press [ENTER]." 
    read -p "" choice
    echo


    # Check the user's selection and prompt accordingly, or exit
    case $choice in
        1)
            prompt_user=""
            incoming_transmission "As you wish. Let's begin... 🤖 🤝 🧑"
            echo
            ;;
        2)
            prompt_user="-y"
            incoming_transmission "Thank you! I'll take it from here. 🤖 ⚙️  🤷"
            echo
            ;;
        3)
            incoming_transmission "👋 Good-bye. I'm off to the bar for an iced-foo. 🍹 🍍🏖️🌴🌺  🌞🏄🌊"
            echo
            exit 0
            ;;
        *)
            incoming_transmission "You've entered an invalid option. ✌️"
            echo
            exit 1
            ;;
    esac

}

# Function to install Docker
install_docker() {

    # Update package lists to endure we are woking with the most current lists
    sudo apt update

    # Ensure non-existence of conflicting packages
    for pkg in "${pkg_conflicts[@]}"; do
        if dpkg -l | grep -q -w "$pkg"; then
            sudo apt-get remove "$prompt_user" "$pkg"
        else
            incoming_transmission "$pkg not installed. Nothing to remove."
        fi
    done

    # Add Docker's official GPG key:
    for required_pkg in "${required_pkgs[@]}"; do
        if dpkg -l | grep -q -w "$required_pkg"; then
            incoming_transmission "$required_pkg already installed."
        else
            sudo apt-get install "$prompt_user" "$required_pkg"
        fi
    done

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install the latest version of Docker
    for docker_pkg in "${docker_pkgs[@]}"; do
        if dpkg -l | grep -q -w "$docker_pkg"; then
            incoming_transmission "$docker_pkg already installed."
        else
            sudo apt-get install "$prompt_user" "$docker_pkg"
        fi
    done

    # Test your new Docker installation with sudo
    sudo docker run hello-world

    # The `docker` group will have been created automatically during the installation process.
    # Let's check if the 'docker' group exists, just in case.
    if grep -q "^docker:" /etc/group; then
        incoming_transmission "The 'docker' group already exists."
    else
        incoming_transmission "Creating the 'docker' group..."
        sudo groupadd docker
        incoming_transmission "The 'docker' group has been created."
    fi

    # Add your usr to the group and update the group to recognize its new member
    incoming_transmission "Adding $user to 'docker' group."
    sudo usermod -aG docker "$user"
    
    # Ensure we own the config directory and its contents
    incoming_transmission "Creating '$home/.docker' direcotry"
    mkdir "$home/.docker"

    # Changing ownership of '$home/.docker' directory to $user
    incoming_transmission "Giving ownership of $home/.docker to $user"
    sudo chown "$user":"$user" "$home/.docker" -R

    incoming_transmission "Modifying $home/.docker to give 'docker' group read, write, and execute permissions."
    sudo chmod g+rwx "$home/.docker" -R
    ls -lshtar "$home/.docker"
    
    # Let's make some magic and greet the world.
    docker run hello-world

    incoming_transmission "Docker installation complete. You'll need to reboot your system/VM, or restart your container for some of the changes to take effect."
    echo
    echo -e "\e[5mREBOOT\e[0m"
    echo
}

# Show ASCII art splash screen
display_cover

# Check Bash version before proceeding
check_bash_version

# Check for the minimum packages required for this script
check_base_essentials

# Call the function to check APT repository connectivity
check_apt_repository

# Call the function 'choose_your_path'
choose_your_path

# Call the installation function
install_docker
