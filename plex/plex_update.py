#!/usr/bin/env python3

#from tqdm import tqdm
import feedparser
import base64
import requests
import http
import urllib
import os, sys
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
import logging
import time
import plex_config
import plex_token
import ssl

REPO_DIR = ""
INSTALL = "False"

class StreamToLogger(object):
    """
    Fake file-like stream object that redirects writes to a logger instance.
    """
    def __init__(self, logger, log_level=logging.INFO):
       self.logger = logger
       self.log_level = log_level
       self.linebuf = ''

    def write(self, buf):
       for line in buf.rstrip().splitlines():
          self.logger.log(self.log_level, line.rstrip())

logging.basicConfig(
    level=logging.DEBUG,
    #format='%(asctime)s:%(levelname)s:%(name)s:%(message)s',
    format='%(asctime)s %(message)s',
    datefmt='%m/%d/%Y %I:%M:%S %p',
    filename='./plex_update.log',
    filemode='a'
)

stdout_logger = logging.getLogger('STDOUT')
sl = StreamToLogger(stdout_logger, logging.INFO)
sys.stdout = sl

stderr_logger = logging.getLogger('STDERR')
sl = StreamToLogger(stderr_logger, logging.ERROR)
sys.stderr = sl

## Hack to make it so requests and feedparser work with a cert mismatch
if hasattr(ssl, '_create_unverified_context'):
    ssl._create_default_https_context = ssl._create_unverified_context

#d = feedparser.parse("https://plex.tv/pms/servers.xml?X-Plex-Token=%s" % (plex_config.server, plex_token.token))
auth = ('%s:%s' % (plex_config.username, plex_config.password)).replace('\n', '')
base64string = base64.b64encode(auth.encode('ascii'))
txdata = ''
headers={'Authorization': "Basic %s" % base64string.decode('ascii')}
conn = http.client.HTTPSConnection("plex.tv")
conn.request("GET","/pms/servers.xml",txdata,headers)
response = conn.getresponse()
print(response)
d = feedparser.parse(response)
print(len(d['feed']['mediacontainer']['Server']))
if d['feed']['mediacontainer']['server'][2]['owned'] == 1:
    print(d['feed']['mediacontainer'])


logging.info('Starting plex update process')
data = {'download': '0', 'X-Plex-Token': '%s' % plex_token.token}
r = requests.put("%s/updater/check" % plex_config.server, params=data, verify=False)
#print(r)
logging.info('Checking for plex update')
success = r.status_code
print(success)
if success == 200:
    logging.info('Check successful')
    d = feedparser.parse("%s/updater/status?X-Plex-Token=%s" % (plex_config.server, plex_token.token))
    logging.info("\"GET /updater/status?X-Plex-Token=%s\"" % (plex_token.token))
#    print()"something goes here")
#    print(d)
    size=d['feed']['mediacontainer']['size']
    if size == '1':
        update_url = d['feed']['release']['downloadurl']
        new_version = d['feed']['release']['version']
        dl = os.path.isfile("%splexmediaserver-%s.x86_64.rpm" % (REPO_DIR, new_version))
        if dl == True:
            logging.info('Update found but already downloaded')
            #print("Already Downloaded")
            logging.info('------------------------')
            exit(0)
        else:
            logging.info('Update found, downloading...')
            urllib.request.urlretrieve ("%s" % update_url, "%splexmediaserver-%s.x86_64.rpm" % (REPO_DIR, new_version))
            logging.info('=== Downloaded %splexmediaserver-%s.x86_64.rpm ===', REPO_DIR, new_version)
            os.system('createrepo --database %s' % REPO_DIR)
            logging.info('Repo updated')
            os.system('yum clean all')
            if INSTALL == 'True':
                logging.info('Set to install plex')
                os.system('yum update plexmediaserver -y')
                logging.info('Plex has been updated')
                os.system('service plexmediaserver stop')
                time.sleep(30)
                os.system('service plexmediaserver start')
                logging.info('Plex Media Server has been restarted')
                logging.info('Plex update complete')
                logging.info('------------------------')
                #print("Plex has been updated")
                exit(0)
            else:
                logging.info('Plex has been downloaded and is ready for install')
                logging.info('------------------------')
                exit(0)
            #r = requests.get("%s" % update_url, stream=False)
            #with open("%splexmediaserver-%s.x86_64.rpm" % (REPO_DIR, new_version), "wb") as handle:
            #    for data in tqdm(r.iter_content()):
            #        handle.write(data)
            #print(update_url)
            #print(new_version)
    else:
        logging.info('No Update Available')
        logging.info('------------------------')
        #print("No Update Available to stdout")
        exit(0)
else:
    logging.info('Failed to check for an update')
    logging.info('------------------------')
    #print("Failed to check for update")
    exit(1)
