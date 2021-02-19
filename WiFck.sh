#!/usr/bin/env bash

# wifck
# https://github.com/xG4L1L30x/wifck
# Dev: G4L1L30
# Version: -

H='\033[30m'
R='\033[31m'
G='\033[32m'
B='\033[34m'
P='\033[35m'
C='\033[36m'
Y='\033[33m'
W='\033[97m'
bgH='\033[40m'
bgR='\033[41m'
bgG='\033[42m'
bgB='\033[44m'
bgP='\033[45m'
bgC='\033[46m'
bgY='\033[43m'
bgW='\033[107m'
BD='\033[1m'
Q='\033[0m'
in="${C}[${Q}"
out="${C}]${Q}"

trap quit INT

if [[ "$(id -u)" -ne 0 ]]; then
		echo -e "[${R}${BD}!${Q}] This script must run as root!"
		exit
fi

function banner() {
	printf """
${BD}${C} █     █░ ██▓${R}  █████▒▄████▄   ██ ▄█▀${Q}
${BD}${C}▓█░ █ ░█░▓██▒${R}▓██   ▒▒██▀ ▀█   ██▄█▒${Q}
${BD}${C}▒█░ █ ░█ ▒██▒${R}▒████ ░▒▓█    ▄ ▓███▄░${Q}
${BD}${C}░█░ █ ░█ ░██░${R}░▓█▒  ░▒▓▓▄ ▄██▒▓██ █▄ V1.0${Q}
${BD}${C}░░██▒██▓ ░██░${R}░▒█░   ▒ ▓███▀ ░▒██▒ █▄${Q}
${BD}${C}░ ▓░▒ ▒  ░▓  ${R} ▒ ░   ░ ░▒ ▒  ░▒ ▒▒ ▓▒${Q}
${BD}${C}  ▒ ░ ░   ▒ ░${R} ░       ░  ▒   ░ ░▒ ▒░${Q}
${BD}${C}  ░   ░   ▒ ░${R} ░ ░   ░        ░ ░░ ░ ${Q}
${BD}${C}    ░     ░  ${R}       ░ ░      ░  ░${Q}
${BD}${C}	           ${R}         ░${Q}
"""
}

function iface() {
	echo -e "${in}${Y}${BD} INTERFACE ${Q}${out}\n"
  ip link | grep -E "^[0-9]+" | awk -F':' '{ print $2 }' 1> ./tmp/iface.txt
  cat ./tmp/iface.txt | awk '{ print $1 }' | awk '{ print "\033[36m[\033[0m" "\033[32m\033[1m"NR "\033[0m\033[36m]\033[0m " $s }'
	echo -ne "\n${BD}${R}${HOSTNAME}${G}@${C}WiFck${Q} >> " ; read set_iface
	iface=$(sed "${set_iface}!d" ./tmp/iface.txt | awk '{ print $1 }')
	if [[ -z ${iface} ]] || [[ ${set_iface} == 0 ]] || [[ $set_iface =~ [a-zA-Z]+ ]]; then
		echo -e "${in}${BD}${R}!${Q}${out} Invalid Option! Please type a number.\n"
		iface
	fi
}

function quit() {
  rm ./tmp/*
  exit
}

banner
iface
