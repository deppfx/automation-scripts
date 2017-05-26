#! /usr/bin/env bash
#title           :buildrpm.sh
#description     :This script downloads all individual jar files and builds them into rpms
#author          :Naga Deepak Pothuraju
#date            :20170525
#version         :0.1
#usage           :bash buildrpm.sh
#notes           :Install vim to use this script.
#==============================================================================

printf "This script builds the rpms for a given sprint & build number\n ================"


# Take user input
printf "Enter the sprint number: "
read sprint
printf "Enter the build number: "
read build

url="http://gec-maven-nexus.walmart.com/nexus/content/repositories/inkiru_releases/ink_sprint$sprint/$build/"
lst=( $(wget -qO- $url | grep -oE "\"http://.*.jar\"" | tr -d '"') )
rpmroot="/root/rpmbuild"




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
install -m 0755 -d \$RPM_BUILD_ROOT/app/home/inkiru/inkadmin/lib/
install -m 0755 $filename \$RPM_BUILD_ROOT/app/home/inkiru/inkadmin/lib/$filename
%clean
rm -rf \$RPM_BUILD_ROOT
%post
%files
%dir /app/home/inkiru/inkadmin/lib/
/app/home/inkiru/inkadmin/lib/$filename
EOF


# Build the rpms
rpmbuild -ba /tmp/$filewithoutext.spec
#yum install -y $rpmroot/RPMS/noarch/$filewithoutext*noarch.rpm


# Upload them to the repositories
cp -ra $rpmroot/RPMS/noarch/$filewithoutext*noarch.rpm /app/inkirurepo/

done

# Initialize the repo with fresh data
createrepo /app/inkirurepo/.
