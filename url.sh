#!/bin/bash

# Set color variables
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'
nc='\033[0m' # No Color

# Set info and error prefixes
info="${green}[INFO]${nc}"
error="${red}[ERROR]${nc}"

# Function to check if command exists
function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if pv is installed
if ! command_exists pv; then
  echo -e "${error} pv is not installed. Please install it first."
  exit 1
fi

# Check if apktool is installed
if ! command_exists apktool; then
  echo -e "${error} apktool is not installed. Please install it first."
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo -e "${error} Usage: $0 <apk-file>"
  exit 1
fi

apk_file="$1"
if [[ ! -f "$apk_file" ]]; then
  echo -e "${error} $apk_file not found."
  exit 1
fi

temp_dir=$(mktemp -d)

# Print new logo
printf "${green}"
cat << "EOF"
MMMMMMMMMMMMMMMMMMMMMN0dllodxkkkk0KWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMNKko:'.,,;;:lxxxONMMMXONMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNOd:.. .,cloxl,. .;OMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKKkl:.   ..     kMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMXxl:cclodddd00l        .cOWMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMM0l:lkKXXXKKKKKKKXk.          .cOWMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMWk,c0XKKKKKKKKKKKKXO;.  .;xd;.     .lXMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMM0,lKXKKKKKKKKKKKKKXd'.  ,KK0KN0l.      ;0MMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMd'0XKKKKKKKKKKKX0KNc.   cX00000Xkco,     .WMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMo'XXKKKKKKKKKKX0:x0l  ..cN0000000KO.O0:..oNMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMO.KXKKKKKKKKKXXc0Ndd,kxWNkxX00000OOKx.NMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMM,lNKKKKKKKKKX0dXkxkXx:ocXMkkK000OOOON'lMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMN 0XKKKKKKKKX0xkxKN0lo0;.cX0cX00OOOOOKo'MMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMX KXKKKKKKKKKKcxx0c:od. ,WWX,00OOOOOOKd.MMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMW.kXKKKKKKKKKXd. .'.  .cWMMW.OKOOOOOOK:;MMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMc,NKKKKKKKKXxl'     cKNWMNW0xod00OOOX.kMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMN.dNKKKKKKXoc.  ;d,  cxOx0dlNMXdld0X;;WMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMK.xNKKKXKc,   oXKKKOdl;..;KMMMMWl..'NMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMX,:XXXO;.  .kX0000000Kk'  ....   :WMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMWx.0x'   .KK00000000OOKk'     .OMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMNc.   ;XK00000000OOOOOXd  ;OMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMX'    odcdOKXXKKKKK0ko:;:xNMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

EOF
printf "${nc}"

printf $"${info} Decompiling the apk\n"
(
  apktool d -f "$apk_file" -o "$temp_dir" 2>&1 | 
  sed -u 's/^/XXX\n/' | 
  pv -s `du -s "$temp_dir" | awk '{print $1}'` -c -N "Decompiling $apk_file..." > /dev/null
)

if [[ $? -ne 0 ]]; then
  echo -e "${error} Failed to decompile $apk_file."
  rm -rf "$temp_dir"
  exit 1
fi

printf $"${info} Extracting endpoints\n"
links=$(pwd)/$(basename "$apk_file" .apk)-endpoints.txt
grep -rhoE 'https?://[^/"]+(/\S+)?' "$temp_dir" | sort | uniq > "$links"
if [[ ! -s "$links" ]]; then
  echo -e "${error} No endpoints found in $apk_file."
  rm -rf "$temp_dir" "$links"
  exit 1
fi

printf $"${info} Endpoints saved in: $links\n"

printf $"${green} DONE!\n"
rm -rf "$temp_dir"
