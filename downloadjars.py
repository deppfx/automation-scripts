#! /usr/bin/env python
import requests
import urllib2
import re
from clint.textui import progress

sprint   = int(raw_input("Enter the sprint number: "))
build    = int(raw_input("Enter the build number: "))
url = "http://gec-maven-nexus.walmart.com/nexus/content/repositories/inkiru_releases/"+"ink_sprint"+str(sprint)+"/"+str(build)+"/"

#connect to a URL
website = urllib2.urlopen(url)

#read html code
html = website.read()

#use re.findall to get all the links
links = re.findall('"(http://.*jar?)"', html)

print "Building rpms for Sprint", sprint , "and Build", build

#function to download a given link
def download_file(link):
    downloadfile = requests.get(link, stream=True)
    filename = link.split("/")[-1]
    r = requests.get(link)
    filesize = int(r.headers.get('content-length'))

    print "Size is", filesize/(1024*1024) + 1, "MB"
    print "Downloading", filename

    with open(filename, "wb") as f:
        for chunk in progress.bar(downloadfile.iter_content(chunk_size=1024), expected_size=(filesize/1024) + 1):
            if chunk: # filter out keep-alive new chunks
                f.write(chunk)
        return filename

#Download all files from the links generayed
for link in links:
    download_file(link)
