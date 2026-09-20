#!/usr/bin/env python3
import sys

REPO_PREFIX = f'kernel/platform/kernel-{sys.argv[1]}/'

print('<manifest>')

with open('.repo/project.list', 'r') as f:
    for line in f:
        if line.startswith(REPO_PREFIX):
            print(f'  <project path="{line[len(REPO_PREFIX) :].strip()}" />')

print('</manifest>')
