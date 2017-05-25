#! /usr/bin/env python
import requests


def download_file():
    with requests.session() as s:
        payload     = {'uid': 'xxxx', 'pwd': 'yyyy'}
        loginurl    = 'http://www.g1.com/Support/login.asp'
        url         = 'http://www.g1.com/Support/login.asp?Source=/Support/getfile.asp~fn=DPV\\OPEN_SYSTEM\\DPV022017_200.zip&type=db&uid=xxxx&asset=1-L6IHP&dbasset=1-L6IIL&rID=1.12185305356979'
        downloaddpv = 'http://dl.g1.com/Release/databases/DPV/OPEN_SYSTEM/DPV022017_200.ZIP'
        downloaduss = 'http://dl.g1.com/Release/databases/USS/OPEN_SYSTEM/USS032017_1000.ZIP'
        headers     = {'Host': 'www.g1.com', 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:51.0) Gecko/20100101 Firefox/51.0', 'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8', 'Accept-Language': 'en-US,en;q=0.5', 'Referer': 'http://www.g1.com/Support/login.asp?source=/Support/getfile.asp~fn%3DDPV%5C%5COPEN%5FSYSTEM%5C%5CDPV022017%5F200%2Ezip%26type%3Ddb%26uid%3Dxxxx%26asset%3D1%2DL6IHP%26dbasset%3D1%2DL6IIL%26rID%3D1%2E12185305356979', 'Cookie': 'UserID=xxxx; lastVisit=2%2F27%2F2017+3%3A49%3A52+PM; ASPSESSIONIDQQTSCQAT=BMFJNPFBEKPIFMMAAFNFOCBD; ASPSESSIONIDSQQRATBT=CLBGKPFBDBDAJNMMAOCGBFEJ; ASPSESSIONIDQSSSCRAS=OCMDJPFBLNCFHFNMCJLPEEDA; SiebUserID=LastLogin=2%2F27%2F2017+4%3A17%3A20+PM&UserID=xxxx; ASPSESSIONIDQSQQBSAT=EGJDNPFBHHPNDHFHOGGPFNGJ; ASPSESSIONIDACDARTTR=GHENPMPBIFINAKONEFEBDNEI; ASPSESSIONIDCCDBRTSQ=PMEJANPBDLLKGJEKCGMHPAMO', 'DNT': '1', 'Connection': 'keep-alive', 'Upgrade-Insecure-Requests': '1'}
    
    ## Fetch login page
        s.get(loginurl)
    
    # post to the login form
        r = s.post(url, data=payload)
    
    # downloading the db file
    for downloadurl in {downloaduss, downloaddpv}:
        downloadfile = s.get(downloadurl, stream=True, headers=headers)
        local_filename = downloadurl.split("/")[-1]
        print 'Downloadurl is:', downloadurl
#        with open(local_filename, 'wb') as f:
#            for chunk in downloadfile.iter_content(chunk_size=1024): 
#                if chunk: # filter out keep-alive new chunks
#                    f.write(chunk)
#                    #f.flush() commented by recommendation from J.F.Sebastian
#            return local_filename

download_file()
