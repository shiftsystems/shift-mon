#!/usr/local/bin/python
import requests
import sys
r = requests.get('http://localhost:8490/health')
if r.status_code == 200:
    print('Health Check Passed')
    sys.exit(0)
else:
    print('Health Check failed')
    sys.exit(1)

