#!/usr/bin/env python
# -*- coding: utf-8 -*-
#http://newapi.meipai.com/live_channels/programs.json?from=1&page=1&count=100

import httplib
conn = httplib.HTTPConnection("192.168.2.2",8898,False,10)
conn.request("GET", "/live_channels/programs.json?from=1&page=1&count=100")
conn.timeout
response = conn.getresponse()
print response

data = response.read()
if data:
    print data
else:
    print ("no data to read")