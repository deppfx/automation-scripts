#! /usr/bin/env bash
#title           :buildrpm.sh
#description     :This script downloads all individual jar files and builds them into rpms
#author          :Naga Deepak Pothuraju
#date            :20170727
#version         :0.1
#usage           :bash buildrpm.sh
#notes           :Install vim to use this script.
#==============================================================================
# This script needs a proxy server running on any machine in EDC

# Setting some fancy colors
red=`tput setaf 1`
yellow=`tput setaf 3`
reset=`tput sgr0`

# Variables
proxy="10.63.69.170"
ip=`hostname -i`
proxyport="3128"
url="http://gec-maven-nexus.walmart.com/nexus/content/repositories/inkiru_releases"
extlibs="extlibs.tar.gz"
inkkyweb="web.tar.gz"
jarlist=( $(wget -qO- $url | grep -oE "\"http://.*.jar\"" | tr -d '"') )
tmpdir=$(mktemp -d)
deploydir=~/inkiru
inkkydir=~/inkiru/bin/InkkyMain
light=0


# Take user input
clear
printf ${yellow}"Enter only the sprint number. Eg: 108 ---> "${reset}
read sprint
printf ${yellow}"Enter only the build number. Eg: 12   ---> "${reset}
read build



# Complete URL
url=${url}/ink_sprint${sprint}/${build}


# Setting up proxy
proxy_on()
{
    ssh -4 -fN -L ${proxyport}:${proxy}:${proxyport} ${proxy}
    export http_proxy=http://127.0.0.1:${proxyport}
}


# Removing proxy
proxy_off()
{
    unset http_proxy
    for i in $(ps aux | grep '[s]sh -4 -fN -L 3128' | awk '{print $2}'); do kill $i ; done
}


# Create tmp dir
mkdir -p ${tmpdir}

# Create dirs if don't exist
mkdir -p ${deploydir}/lib ${deploydir}/extlibs

# Download
download()
{
    local url=${1}
    echo -e "\n${yellow}Downloading entire directory ${reset}${url}${reset}\n"
    wget --progress=bar -r -l1 -nH --cut-dirs=6 --reject="index.html*","*css*","*png*","${build}"  -P ${tmpdir} ${url} 2>&1 | grep Saving
    echo -e "\b\b\b\b"
    echo "Downloaded ${red}$(ls -1 ${tmpdir}/*| wc -l)${reset} files successfully."
}

if [ ${ip} == "10.1.25.240" ]; then
  proxy_on
  download ${url}
  proxy_off
else
  download ${url}
fi

# Move files to their directories
mv -t "${deploydir}/lib/" ${tmpdir}/*.jar
tar -xf ${tmpdir}/${extlibs} -C ${deploydir}
tar -xf ${tmpdir}/${inkkyweb} -C ${inkkydir}
if [ $? == 0 ]; then
    rm -rf {$tmpdir}
    echo "Moved files into the respective locations. You can continue with the deployment."
else
    echo "ERROR! There seems to be some issue with the script. Please verify before proceeding."
fi
