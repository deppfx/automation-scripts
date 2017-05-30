#! /usr/bin/env bash
#title           :buildrpm.sh
#description     :This script downloads all individual jar files and builds them into rpms
#author          :Naga Deepak Pothuraju
#date            :20170525
#version         :0.1
#usage           :bash buildrpm.sh
#notes           :Install vim to use this script.
#==============================================================================
# This script assumes that the machine this is being run on has an active yum repo server running on it at the location $repodir below.

# Setting some fancy colors
red=`tput setaf 1`
yellow=`tput setaf 3`
reset=`tput sgr0`
ip=`hostname -i`

# Check if rpmbuild tools are already installed
if [ "$ip" == "10.242.251.245" ];
then
  if rpm -qa | grep rpmdevtools 2>&1 > /dev/null && rpm -qa | grep rpm-build 2>&1 > /dev/null ;
  then
    continue
  else
    printf $yellow"ERROR: Please install packages "rpmdevtools" & "rpm-build" before continuing.\n"$reset
    printf $reset"Type [$red y $reset] to allow me to install them now: "
    read agree
      if [ $agree == "y" ];
      then
        yum install rpmdevtools rpm-build
      continue
      else
      printf $yellow"This script is exiting now.\n"$reset
      exit 1
      fi
  fi
else
echo "This script is not yet fully designed to run on any other machine except 10.242.251.245. Please take a look at the script before proceeding."
exit 1
fi

# Start of the script
printf "This script builds the rpms for a given sprint & build number\n ================\n"

# Take user input
printf "Enter the sprint number: "
read sprint
printf "Enter the build number: "
read build

# Variables
url="http://gec-maven-nexus.walmart.com/nexus/content/repositories/inkiru_releases/ink_sprint$sprint/$build/"
lst=( $(wget -qO- $url | grep -oE "\"http://.*.jar\"" | tr -d '"') )
rpmroot="/root/rpmbuild"
repodir="/var/www/html/repos/inkiru/$sprint-$build"
numbuilds=6

# Download all the jars
for i in "${lst[@]}"
do
filename=$( echo $i | awk -F "/" '{print $NF}' )
filewithoutext=$( echo $i | awk -F "/" '{print $NF}' | awk -F "." '{print $1}' )

  if [ -a $filename ]
    then rm -f $filename
  fi
curl $i --create-dirs -o $rpmroot/SOURCES/$filewithoutext-$sprint/$filename



# Tar the jars before rolling into rpms
cd $rpmroot/SOURCES/
tar cvzf $filewithoutext-$sprint.tar.gz $filewithoutext-$sprint
cd -



# Create individual spec files from the template
cat > /tmp/$filewithoutext.spec <<-EOF
Name:           $filewithoutext
Version:        $sprint
Release:        $build
Summary:        Inkiru Apps
URL:        $url

BuildArch:      noarch
Source0:        %{name}-%{version}.tar.gz
License:        Proprietary
Group:          Inkiru
BuildRoot: %{_tmppath}/%{name}-buildroot
%description
This package installs the $filewithoutext application.
%prep
%setup -q
%build
%install
rm -rf %{buildroot}
install -m 0755 -d \$RPM_BUILD_ROOT/home/inkiru/inkadmin/lib/
install -m 0755 $filename \$RPM_BUILD_ROOT/home/inkiru/inkadmin/lib/$filename
%clean
rm -rf \$RPM_BUILD_ROOT
%post
%files
%dir /home/inkiru/inkadmin/lib/
/home/inkiru/inkadmin/lib/$filename
EOF


# Build the rpms
rpmbuild -ba /tmp/$filewithoutext.spec
#yum install -y $rpmroot/RPMS/noarch/$filewithoutext*noarch.rpm


# Copy the rpms to the repositories
cp -ra $rpmroot/RPMS/noarch/$filewithoutext*noarch.rpm $repodir/
done

# Cleaning repositories older than 4 builds
if [ $(find $repodir/../* -maxdepth 0 -type d -print | wc -l) -gt $numbuilds  ] ; then
  ls -d -1 $repodir/../* | head -n -$numbuilds | xargs echo
fi

# Initialize the repo with fresh data
if find "$repodir" -mindepth 1 -print -quit | grep -q .; then
    echo "Updating repository..."
    createrepo --update $repodir/.
else
    echo "This looks like a new repository, initializing it..."
    mkdir -p $repodir
    createrepo $repodir/.
fi
