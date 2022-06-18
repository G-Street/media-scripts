#!/usr/bin/env python3

'''
This script can be used to get a plex
token that can be used in other
applications and automations.
'''

import base64, json, getpass
import http.client
#from pprint import pprint
import configparser
import platform
import plex_config

PLATFORM = platform.system()
PLATFORM_VERSION = platform.release()
Config = configparser.ConfigParser()

file = Config.read(plex_config.conf_file)

## Auth against plex.tv
auth = ('%s:%s' % (plex_config.username, plex_config.password)).replace('\n', '')
base64string = base64.b64encode(auth.encode('ascii'))
txdata = ''
headers={'Authorization': "Basic %s" % base64string.decode('ascii'),
                'X-Plex-Client-Identifier': "Plex Token",
                'X-Plex-Device-Name': "Plex Updater",
                'X-Plex-Product': "Plex Updater",
                'X-Plex-Platform': PLATFORM,
                'X-Plex-Platform-Version': PLATFORM_VERSION,
                'X-Plex-Version': "1.0"}

conn = http.client.HTTPSConnection("plex.tv")
conn.request("POST","/users/sign_in.json",txdata,headers)
response = conn.getresponse()
# print(response.status, response.reason)
data = response.read()

## Parse the json and rturn a plex token
json = json.loads(data)
token=json["user"]["authToken"]

target = open(plex_config.conf_file, 'w')
Config.set('server','token',token)
Config.write(target)
target.close()

print("Plex Token: %s" % (token))

conn.close()
