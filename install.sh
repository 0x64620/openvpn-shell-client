#!/usr/bin/env bash


# GNU GPL 3.0
#
#
# (c) 2024, 0x64.dev
#
# There is rly nothing to do. Rly. In src is only one shell file. Just replace var with real conf path and copy to the your  .$SHELLrc file. gl.



infoRed() { 
    echo -e "[\e[1;31m $1 \e[0m] $2"
}
infoYellow() { 
    echo -e "[\e[1;33m $1 \e[0m] $2"
}
infoGreen() { 
    echo -e "[\e[1;32m $1 \e[0m] $2"
}
infoBlue() { 
    echo -e "[\e[1;34m $1 \e[0m] $2"
}
checkPkg() {
    if ! dpkg -s "$1" >/dev/null 2>&1; then
        infoYellow INFO "Package $1 is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y "$1"
    else
        infoGreen INFO "Package $1 is present."
    fi
}
checkInstalled() {
    if [ ! -d ~/.config/openvpn/donotdelete ];
        then
            sleep 1
        else 
            infoRed ERROR "openvpn-simple-client is already installed."
            exit 1
    fi

}
askOvpnConfig() {
    infoBlue RDY "Enter your OpenVPN .ovpn or .conf file location:"
    read openVpnConfigFile
    if [ -f "$openVpnConfigFile" ]; then
        infoGreen OK "OpenVPN configuration file is present"
        echo "openVpnConfigFile=\"$openVpnConfigFile\"" > src/simpleclient.conf
    else
        infoRed FATAL "OpenVPN configuration file was not found."
        exit 1
    fi
}
checkOSCompatibility() {
    if [ -f /etc/debian_version ]; 
        then
            infoGreen INFO "System compatibility OK."
        else
            infoRed FATAL "Sorry, only Debian-based distros can use automatic install, open install.sh with text editor and read header."
            exit 1
        fi
}
checkDirectory() {
    if [ ! -d ~/.config/openvpn ]; then
        infoRed ! "~/.config/openvpn/ not found"
        infoYellow ... "Creating ~/.config/openvpn/"
        mkdir -p ~/.config/openvpn
    fi   
}
checkShell () {
        if [ "$SHELL" == "/usr/bin/bash" ]; then
            PROFILE_FILE=~/.bashrc
        elif [ "$SHELL" == "/usr/bin/zsh" ]; then
            PROFILE_FILE=~/.zshrc
        else
            infoRed FATAL "Shell not compatible, open install.sh with text editor and read header. Your shell is $SHELL"
            exit 1
        fi
}
installMain () {
    infoYellow INFO "Copying files"
    cp src/* ~/.config/openvpn/
    chmod 777 ~/.config/openvpn/*
    mkdir ~/.config/openvpn/donotdelete
    echo "Delete this folder only if you want to reinstall openvpn-simple-client" > ~/.config/openvpn/donotdelete/readme.txt
        
    if ! grep -q 'source ~/.config/openvpn/client.sh' "$PROFILE_FILE"; then
        infoYellow INFO "Adding to shell"
        echo 'source ~/.config/openvpn/client.sh' >> "$PROFILE_FILE"
    else
        infoRed ERROR "Shell file is already pathed"
    fi

}

infoBlue INIT "Starting openvpn-simple-client installation."
checkPkg screen
checkPkg openvpn
checkDirectory
checkInstalled
checkOSCompatibility
checkShell
askOvpnConfig
installMain
infoGreen DONE "Installed. Restart your terminal!"
