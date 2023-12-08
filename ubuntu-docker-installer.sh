#!/bin/bash

# Function to print text one character at a time with a random delay
incomming_transmission() {
    local text="$1"  # Get the text to print from the first argument
    local min_delay=0.03  # Minimum delay in seconds
    local max_delay=0.09  # Maximum delay in seconds

    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:i:1}"  # Print a single character without newline
        # Generate a random delay within the specified range
        local random_delay=$(awk -v min="$min_delay" -v max="$max_delay" 'BEGIN{srand(); print min+rand()*(max-min)}')
        sleep "$random_delay"  # Wait for the random delay
    done

    echo  # Print a newline to move to the next line
}

display_cover() {

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
 ........:| -|- o-o\_:_\|o-/:....../...........................
 ._🌊._._._\=\====o==o==o=/:.._._._._._._.🌊_._._🌊._._._._._._
 _._._.🌊_._\_\ ._._._._.:._._._🌊._._._._._._._._.🌊_._._._._.
 ._🌊._._._._._._._🌊._._._._._._._._._._.🌊_._._._._._._.🌊_._
EOF

    incomming_transmission " ...... Docker Installation Script for Ubuntu & Bash 4.0 🌊.... "
    incomming_transmission " .............................................................. "

}

# Function: Check user's Bash version for compatibility
check_bash_version() {
    display_cover
    echo
    incomming_transmission "Greetings, Hologram!"
    echo
    sleep 0.741
    incomming_transmission "Checking system requirements, beginning with bourne shell."
    sleep 1.25

    required_version="4.0" # Minimum required Bash version
    current_version="$(bash --version | head -n1 | awk '{print $4}' | cut -d'.' -f1,2)"

    if [[ "$(incomming_transmission "$required_version <= $current_version" | bc)" -eq 1 ]]; then
        incomming_transmission "You are currently running bash version $current_version. Bashing on!"
        echo
    else
        incomming_transmission "You are currently running bash version $current_version. Bash version $required_version or higher is required."
        echo
        exit 1
    fi
}

check_internet_connection() {
    incomming_transmission "Checking for Internet access..."
    sleep 1.25

    local ping_count=3  # Number of ping attempts
    local ping_server="8.8.8.8"  # Google's public DNS server

    if ping -c $ping_count $ping_server >/dev/null 2>&1; then
        incomming_transmission "It seems we have access. So far, so good!"
        echo
    else
        incomming_transmission "No Internet connection detected. Please check your network settings, or jiggle your network cable."
        echo
        exit 1
    fi
}

check_apt_repository() {
    incomming_transmission "Checking for access to package repositories..."
    sleep 0.75

    local apt_repository="archive.ubuntu.com"
    local apt_port="80"

    if nc -z -w 5 $apt_repository $apt_port >/dev/null 2>&1; then
        incomming_transmission "APT repository ($apt_repository) is reachable. Let us proceed."
        echo
    else
        incomming_transmission "Unable to reach APT repository ($apt_repository).While we seem to have access to the Internet, I am unable to reach the package repositories.Please check your network settings."
        echo
        exit 1
    fi
}

# Check Bash version before proceeding
check_bash_version

# Call the function to check for an Internet connection
check_internet_connection

# Call the function to check APT repository connectivity
check_apt_repository

# Prompt the user for their prefered installation experience
incomming_transmission "Choose your installation experience..."
incomming_transmission "1. Install Docker with prompts. 🤖 🤝 🧑 Interactive installation."
incomming_transmission "2. Install Docker without prompts. 🤖 ⚙️  🤷 Fully automated installation."
incomming_transmission "3. End program. 🤖 🔫 💥 💥 Terminate the execution of this script."
echo
sleep 0.5

incomming_transmission "What is your preference? 1, 2, or 3?" 
read -p "" choice
echo

prompt_user=""

# Check the user's selection and prompt accordingly, or exit
case $choice in
    1)
        prompt_user="-y"
        incomming_transmission "As you wish. Let's begin... 🚢"
        echo
        ;;
    2)
        prompt_user=""
        incomming_transmission "Thank you! I'll take it from here. 🚢 🚢"
        echo
        ;;
    3)
        incomming_transmission "👋 Good-bye. I'm off to the bar for an iced-foo. 🍹 🍍🏖️🌴🌺  🌞🏄🌊"
        echo
        exit 0
        ;;
    *)
        incomming_transmission "You've entered an invalid option. ✌️"
        echo
        exit 1
        ;;
esac

exit 0

# Declare thy arrays
pkg_conflicts=("docker.io" "docker-doc" "docker-compose" "docker-compose-v2" "podman-docker" "containerd" "runc")
required_pkgs=("ca-certificates" "curl" "gnupg")
docker_pkgs=("docker-ce" "docker-ce-cli" "containerd.io" "docker-buildx-plugin" "docker-compose-plugin")

# Function to install Docker
install_docker() {
    # Update package lists to endure we are woking with the most current lists
    sudo apt update

    # Ensure non-existence of conflicting packages
    for pkg in "${pkg_conflicts[@]}"; do
        if dpkg -l | grep -q -w "$pkg"; then
            sudo apt-get remove "$prompt_user" "$pkg"
        else
            incomming_transmission "$pkg not installed. Nothing to remove."
        fi
    done

    # Add Docker's official GPG key:
    for required_pkg in "${required_pkgs[@]}"; do
        if dpkg -l | grep -q -w "$required_pkg"; then
            incomming_transmission "$required_pkg already installed."
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
            incomming_transmission "$docker_pkg already installed."
        else
            sudo apt-get install "$prompt_user" "$docker_pkg"
        fi
    done

    # Test your new Docker installation with sudo
    sudo docker run hello-world

    # The `docker` group will have been created automatically during the installation process.
    # Let's check if the 'docker' group exists, just in case.
    if grep -q "^docker:" /etc/group; then
        incomming_transmission "The 'docker' group already exists."
    else
        incomming_transmission "Creating the 'docker' group..."
        sudo groupadd docker
        incomming_transmission "The 'docker' group has been created."
    fi

    # Add your usr to the group and update the group to recognize its new member
    sudo usermod -aG docker $USER && newgrp docker

    # Ensure we own the config directory and its contents
    sudo chown "$USER":"$USER" "$HOME/.docker" -R
    sudo chmod g+rwx "$HOME/.docker" -R

    # Let's make some magic and greet the world.
    docker run hello-world

    incomming_transmission "Docker installation complete."
}

# Call the installation function
install_docker
