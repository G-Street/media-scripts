#!/usr/bin/env python

import urllib.request, ssl, certifi
from bs4 import BeautifulSoup
import ssl
import certifi

# site = 'https://horriblesubs.info/shows/one-piece/'
# user_agent = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7'
# hdr = {'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
#         'User-Agent':user_agent,}
#
# request=urllib.request.Request(site,None,hdr)
# page = urllib.request.urlopen(request, context=ssl.create_default_context(cafile=certifi.where()))
# soup = BeautifulSoup(page, features="lxml")
#
# # x = soup.body.find('div', attrs={'class' : 'entry-content', 'class' : 'hs-shows' })
# # x = soup.find('body')
# # y = soup.find_all('a')
#
# print(soup.prettify())
# # print(soup)


html_file = '/Users/jakeireland/Desktop/One Piece – HorribleSubs.html'
