#!/usr/bin/python

import os
import sys
import errno
import fnmatch
import shutil
import hashlib

debug = True

def logmsg(msg):
    if debug:
        logf = open("prebuilt.log", "a")
        logf.write(msg)
        logf.close()

def mkpath(dir):
    try:
        os.makedirs(dir)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

def read_dotd_file(pathname):
    lines = []
    f = open(pathname)
    logical_line = ''
    cont = False
    for line in f:
        line = line.rstrip('\n')
        if line.endswith('\\'):
            cont = True
            logical_line += line.rstrip('\\')
        else:
            cont = False
            logical_line += line
            lines.append(logical_line)
            logical_line = ''
    f.close()
    if cont:
        raise RuntimeError("Ends with a continuation")
    return lines

def read_includes_file(pathname):
    dirs = set()
    f = open(pathname)
    for line in f:
        line = line.rstrip('\n')
        fields = line.split()
        isargval = False
        for arg in fields:
            if isargval:
                if arg.startswith('-I'):
                    raise RuntimeError("Unexpected format")
                dirs.add(arg)
                isargval = False
                continue
            if not arg.startswith('-I'):
                raise RuntimeError("Unexpected format")
            if arg == '-I':
                isargval = True
                continue
            dirs.add(arg[2:])
    f.close()
    return dirs

def file_write_list(pathname, items):
    f = open(pathname, 'w')
    for item in items:
        f.write("%s\n" % (item))
    f.close()

def file_read_list(pathname):
    items = []
    f = open(pathname)
    for line in f:
        items.append(line.rstrip())
    f.close()
    return items

def file_write_dict(pathname, items):
    f = open(pathname, 'w')
    for k, v in items.iteritems():
        f.write("%s %s\n" % (k, v))
    f.close()

def file_read_dict(pathname):
    items = dict()
    f = open(pathname)
    for line in f:
        k, v = line.rstrip().split(' ', 1)
        items[k] = v
    f.close()
    return items

def lcopyfile(src, dst):
    # Create dirs
    try:
        os.makedirs(os.path.dirname(dst))
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

    # Unlink any existing file
    try:
        os.unlink(dst)
    except OSError as e:
        if e.errno != errno.ENOENT:
            raise

    # Try to hardlink
    try:
        os.link(src, dst)
    except OSError as e:
        if e.errno != errno.EXDEV:
            raise
        # Copy
        shutil.copyfile(src, dst)
        shutil.copystat(src, dst)

def lcopytree(src, dst, pattern=None):
    try:
        shutil.rmtree(dst)
    except:
        pass
    for srcpath, srcdirs, srcfiles in os.walk(src):
        dstpath = "%s/%s" % (dst, srcpath[len(src)+1:])
        for srcfile in srcfiles:
            if not pattern is None:
                if not fnmatch.fnmatch(srcfile, pattern):
                    continue
            try:
                os.makedirs(dstpath)
            except OSError as e:
                if e.errno != errno.EEXIST:
                    raise
            lcopyfile("%s/%s" % (srcpath, srcfile), "%s/%s" % (dstpath, srcfile))

def hash_file(filename):
    hasher = hashlib.md5()
    f = open(filename)
    buf = f.read()
    f.close()
    hasher.update(buf)
    return hasher.hexdigest()

def hash_files(filenames):
    hasher = hashlib.md5()
    for filename in sorted(filenames):
        hasher = hashlib.md5()
        f = open(filename)
        buf = f.read()
        f.close()
        hasher.update(buf)
    return hasher.hexdigest()
