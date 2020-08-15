import json
import os, sys
import time
from urllib import request, parse
from urllib.request import urlretrieve

def create(token,region_type,region_data,output_file):
    data = {'token':token,'region':{'type':region_type,'data':region_data}}
    req = request.Request('https://protomaps.com/api/v1/extracts', bytes(json.dumps(data), encoding='utf-8'), {'User-Agent':'urllib'})
    resp = request.urlopen(req)
    poll_url = json.loads(resp.read())['url']
    for i in range(360):
        resp = request.urlopen(url=poll_url)
        result = json.loads(resp.read())
        if 'DownloadUrl' in result:
            urlretrieve(result['DownloadUrl'],output_file)
            break
        time.sleep(5)

create(os.getenv('PROTOMAPS_TOKEN'), 'bbox', [20.72799,118.1036,26.60305,122.9312], os.getenv('OUTPUT'))
