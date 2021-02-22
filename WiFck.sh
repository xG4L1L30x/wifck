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
in="${C}[${Q}${BD}"
out="${C}]${Q}"
input="\n${BD}${R}${HOSTNAME}${G}@${C}WiFck ${G}>> ${Q}"

trap quit INT

if [[ "$(id -u)" != 0 ]]; then
		echo -e "${in}${R}${BD}!${Q}${out} This script must run as root!"
		exit
fi

function banner() {
	printf """
${BD}${C} █     █░ ██▓${R}  █████▒▄████▄   ██ ▄█▀${Q}
${BD}${C}▓█░ █ ░█░▓██▒${R}▓██   ▒▒██▀ ▀█   ██▄█▒${Q}
${BD}${C}▒█░ █ ░█ ▒██▒${R}▒████ ░▒▓█    ▄ ▓███▄░${Q}
${BD}${C}░█░ █ ░█ ░██░${R}░▓█▒  ░▒▓▓▄ ▄██▒▓██ █▄ ${G}V1.0${Q}
${BD}${C}░░██▒██▓ ░██░${R}░▒█░   ▒ ▓███▀ ░▒██▒ █▄${Q}
${BD}${C}░ ▓░▒ ▒  ░▓  ${R} ▒ ░   ░ ░▒ ▒  ░▒ ▒▒ ▓▒${Q}
${BD}${C}  ▒ ░ ░   ▒ ░${R} ░       ░  ▒   ░ ░▒ ▒░${Q}
${BD}${C}  ░   ░   ▒ ░${R} ░ ░   ░        ░ ░░ ░ ${Q}
${BD}${C}    ░     ░  ${R}       ░ ░      ░  ░${Q}
   ${BD}${C}~=:${in} Developed by G4L1L30 ${out}${C}:=~${Q}
${BD}${C}> ${G}https://github.com/xG4L1L30x/WiFck ${C}<${Q}

"""
}

function iface() {
	echo -e "${in}${Y}${BD} INTERFACE ${Q}${out}\n"
  ip link | grep -E "^[0-9]+" | awk -F':' '{ print $2 }' 1> ./tmp/iface.txt
  cat ./tmp/iface.txt | awk '{ print $1 }' | awk '{ print "\033[36m[\033[0m" "\033[32m\033[1m"NR "\033[0m\033[36m]\033[0m " $s }'
	echo -ne ${input} ; read set_iface
	iface=$(sed "${set_iface}!d" ./tmp/iface.txt | awk '{ print $1 }')
	if [[ -z ${iface} ]] || [[ ${set_iface} == 0 ]] || [[ $set_iface =~ [a-zA-Z]+ ]]; then
		echo -e "${in}${BD}${R}!${Q}${out} Invalid Option! Please type a number.\n"
		iface
	else
		check_mode
	fi
}

function check_mode() {
	mode=$(iw $iface info | grep "type")
	if [[ ${mode} != *'monitor'* ]]; then
		echo -e "\n${in}${R}!${Q}${out} Interface is'nt on monitor mode!"
		sleep 1
		echo -e "${in}${Y}*${Q}${out} Change to monitor mode..."
		sleep 2
		change_mode
	else
		echo -e "\n${in}${Y}*${Q}${out} Set ${C}${iface}${Q} to main interface"
	fi
}

function change_mode() {
	airmon-ng start ${iface} > /dev/null 2>&1
	mon=$(ip link | grep -E "^[0-9]+" | awk -F':' '{ print $1 $2 }' | grep "mon")
  if [[ ${mon} == *'mon'* ]]; then
    iface="${iface}mon"
  fi
	mode=$(iw $iface info | grep "type")
	if [[ ${mode} != *'monitor'* ]]; then
		echo -e "${in}${R}!${Q}${out} Interface doesnt supported!"
	else
		echo -e "\n${in}${Y}*${Q}${out} Set ${C}${iface}${Q} to main interface"
	fi
}

function quit() {
  rm ./tmp/*
  exit
}

banner
iface
