#!/usr/bin/env python3

import configparser
import os, sys, getpass

Config = configparser.ConfigParser()

conf_file = "%s/plex_config.ini" % (os.path.abspath(os.path.dirname(sys.argv[0])))

## Check to see if a config file exists and if not, create one
f = os.path.isfile("%s" % (conf_file))
if f == True:
    ## Get values from already created file
    file = Config.read(conf_file)
    username = Config.get('creds', 'username')
    password = Config.get('creds', 'password')
#    token = Config.get('server', 'token')
    server = Config.get('server', 'server')
else:
    user_name = input("plex.tv Username:")
    passwd = getpass.getpass("plex.tv Password:")
    plex_server = input("Plex Server URL (with port):")
    target = open(conf_file, 'w')

    ## Creds section for config file
    Config.add_section('creds')
    Config.set('creds','username',user_name)
    Config.set('creds','password',passwd)

    ## Server section for config file
    Config.add_section('server')
#    Config.set('server','token',plex_token.token)
    Config.set('server','server',plex_server)
    Config.write(target)

    target.close()
    print("Config created")

    ## Get values from the file that was just created
    file = Config.read(conf_file)
    username = Config.get('creds', 'username')
    password = Config.get('creds', 'password')
#    token = Config.get('server', 'token')
    server = Config.get('server', 'server')
