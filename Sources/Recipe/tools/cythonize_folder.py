#!/usr/bin/env python3

from sys import stdout
from os.path import join, dirname, realpath, exists, isdir, basename
from os import listdir, unlink, makedirs, environ, chdir, getcwd, walk
from pprint import pformat
import sh
import zipfile
import tarfile
import importlib
import json
import shutil
import fnmatch
import tempfile
import time
import sh
import sys
import os
import subprocess

cython = '/usr/local/opt/cython/bin/cython'
cython = '/Users/codebuilder/Library/Python/3.11/bin/cython'

python = "/Library/Frameworks/Python.framework/Versions/3.11/bin/python3"

def resolve_cython():
    global cython
    for executable in ('cython', 'cython-2.7'):
        for path in os.environ['PATH'].split(':'):
            if not os.path.exists(path):
                continue
            if executable in os.listdir(path):
                cython = os.path.join(path, executable)
                return


def do(fn):
    print('cythonize:', fn)
    assert fn.endswith('.pyx')
    parts = fn.split('/')
    if parts[0] == '.':
        parts.pop(0)
    modname = parts[-1][:-4]
    package = '_'.join(parts[:-1])

    # cythonize
    print("cython args:", cython, fn)
    subprocess.Popen([cython, "-f", fn], env=os.environ).communicate()

    if not package:
        print('no need to rewrite', fn)
    else:
        # get the .c, and change the initXXX
        fn_c = fn[:-3] + 'c'
        with open(fn_c) as fd:
            data = fd.read()
        modname = modname.split('.')[-1]
        pac_mod = '{}_{}'.format(package, modname)
        fmts = ('init{}(void)', 'PyInit_{}(void)', 'Pyx_NAMESTR("{}")', '"{}",')
        for i, fmt in enumerate(fmts):
            pat = fmt.format(modname)
            sub = fmt.format(pac_mod)
            print('{}: {} -> {}'.format(i + 1, pat, sub))
            data = data.replace(pat, sub)
        print('rewrite', fn_c)
        with open(fn_c, 'w') as fd:
            fd.write(data)



def shprint(command, *args, **kwargs):
    kwargs["_iter"] = True
    kwargs["_out_bufsize"] = 1
    kwargs["_err_to_out"] = True
    indent = 8
    command(*args)
    
    
def cythonize_file(cythonize_script,filename, root):
    
    if filename.startswith(root):
        filename = filename[len(root) + 1:]
    print(filename)
        #print("relative", filename)
    # note when kivy-ios package installed the `cythonize.py` script
    # doesn't (yet) have the executable bit hence we explicitly call it
    # with the Python interpreter
    #shprint(sh.Command(sys.executable),"python3.11", cythonize_script, filename)
    #shprint(sh.Command(python), cythonize_script, filename)
    #do(filename)

def cythonize_build(cythonize_script,root_dir: str):

    for root, dirnames, filenames in walk(root_dir):
        
        for filename in fnmatch.filter(filenames, "*.pyx"):
            cythonize_file(
                cythonize_script, 
                join(root, filename), 
                root_dir
            )
            
if __name__ == "__main__":
    print(sys.argv)
    SCRIPT,BUILD_DIR = sys.argv[1:]
    
    chdir(BUILD_DIR)
    resolve_cython()
    cythonize_build(SCRIPT, BUILD_DIR)
