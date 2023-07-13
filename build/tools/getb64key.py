#!/usr/bin/env python3

import base64
import sys

pkFile = open(sys.argv[1], 'rb').readlines()
base64Key = b""
inCert = False
for line in pkFile:
    if line.startswith(b"-"):
        inCert = not inCert
        continue

    base64Key += line.strip()

print(base64.b16encode(base64.b64decode(base64Key)).lower().decode())
