#!/bin/bash

###########
# This script will install docker , docker-compose and docker-machine
# on Mac OS X or Linux distributions using apt-get (adv packaging tool)
# for package managment.
#
# For OS X it requires boot2docker to be preinstalled. In the same
# directory as this script is an install_boot2docker.sh which requires
# brew to be installed.
##########

RESET='\033[00m'
INFO='\033[01;94mINFO: '${RESET}
WARN='\033[01;33mWARN: '${RESET}
ERROR='\033[01;31mERROR: '${RESET}

command_exists () {
    type "$1" &> /dev/null ;
}

SUDO=''
checkPermissions() {
    echo -e -e "$INFO----> Checking permissions"
    if  [ -x "$(command -v sudo)" ]; then
        SUDO='sudo'
    elif [ $(id -u) != 0 ]; then
        echo -e '----> command sudo was not found. Please rerun as root (with care :)' >&2
        exit 1
    fi
}

# Must have boot2docker installed if using Mac OS X
installMachineMac() {
    $SUDO wget --no-check-certificate -O /usr/local/bin/docker-machine http://docker-machine-builds.evanhazlett.com/latest/docker-machine_darwin_amd64
    $SUDO chmod +x /usr/local/bin/docker-machine
}

installDockerBinMac(){
    $SUDO wget --no-check-certificate -O /usr/local/bin/docker https://get.docker.com/builds/Darwin/x86_64/docker-latest
    $SUDO chmod +x /usr/local/bin/docker
}

installCompose(){
    # Ran into weird permissions on OS X so downloading to CWD then moving, hackariffic
    $SUDO wget --no-check-certificate -O ./docker-compose https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m`
    $SUDO mv docker-compose /usr/local/bin/docker-compose
    $SUDO chmod +x /usr/local/bin/docker-compose
}

linuxDeps(){
    $SUDO apt-get upgrade -y && apt-get update -y && sudo apt-get install -y wget
}

installDockerBinLinux(){
    $SUDO wget --no-check-certificate -qO- https://get.docker.com/ | sh
    $SUDO usermod -aG docker `whoami`
}

# Installing case nightly build from a maintainer Evan
installMachineLinux() {
    $SUDO wget --no-check-certificate -O /usr/local/bin/docker-machine https://docker-machine-builds.evanhazlett.com/latest/docker-machine_linux_amd64
    $SUDO chmod +x /usr/local/bin/docker-machine
}

checkPermissions
UNAME=$(uname)
if [ "$UNAME" = "Darwin" ]; then
    # Mac OS X platform
    echo -e "$INFO-----> Mac OS X detected, checking dependencies"
    if ! [ -x "$(command -v boot2docker)" ]; then
        echo -e "$ERROR-----> Did not find boot2docker in  /usr/local/bin/boot2docker, "
        echo -e "$INFO-----> go to https://docs.docker.com/installation/mac/ for instructions."
        echo -e "$INFO-----> Also checkout Kitematic while you are there, it pretty kewl."
        echo -e "$INFO-----> Alternatively there is a script in this directory [ install_boot2docker.sh ]"
        echo -e "$INFO-----> that you can also use to install boot2docker and brew if it isnt already installed."
        exit 1
    fi
    echo -e "Boot2docker is installed, now checking docker binaries"
    if ! [ -x "$(command -v docker)" ]; then
        echo -e "$INFO-----> Downloading Docker Binary CLI"
        installDockerBinMac
    fi
    if ! [ -x "$(command -v docker-machine)" ]; then
        echo -e "$INFO-----> Downloading Docker Machine CLI..."
        installMachineMac
    fi
    if ! [ -x "$(command -v docker-compose)" ]; then
        echo -e "$INFO-----> Downloading Docker Compose..."
        installCompose
    fi
elif [ "$UNAME" = "Linux" ]; then
    # Linux platform
    echo -e "$WARN----> Linux detected, checking dependencies"
    if ! [ -x "$(command -v wget)" ]; then
        echo -e "$INFO-----> Install the dependency wget..."
        linuxDeps
    fi
    echo -e "-----> Dependencies meet, now pulling Linux binaries"
    if ! [ -x "$(command -v docker)" ]; then
        echo -e "$WARN-----> Docker binary was not found, installing docker binary now..."
        installDockerBinLinux
    fi
    if ! [ -x "$(command -v docker-machine)" ]; then
        echo -e "$INFO-----> Downloading Docker Machine CLI..."
        installMachineLinux
    fi
    if ! [ -x "$(command -v docker-compose)" ]; then
        echo -e "$INFO-----> Downloading Docker Compose..."
        installCompose
    fi
else
  echo -e "$ERROR-----> Unsupported OS:[ $UNAME ] this script only supports ubuntu, debian or OS X"
  exit 1
fi

echo -e "Verify you see a version for each binary below (docker, machine, compose)"
echo -e "Compose and Machine are development HEAD builds with latest patches/features"
if ! [ -x "$(command -v docker)" ]; then
    echo -e "$ERROR-----> Failed to install docker, please see https://docs.docker.com/installation/"
else
    echo -e "$INFO Installed Docker version -----> " $(docker -v)
fi
if ! [ -x "$(command -v docker-compose)" ]; then
    echo -e "$ERROR -----> Failed to install docker compose, please see https://docs.docker.com/compose/install/"
else
    echo -e "$INFO Installed Docker Machine version -----> " $(docker-compose --version)
fi
if ! [ -x "$(command -v docker-machine)" ]; then
    echo -e "$ERROR-----> Failed to install docker machine, https://docs.docker.com/machine/"
else
    echo -e "$INFO Installed Docker Compose version -----> " $(docker-machine --version)
fi


