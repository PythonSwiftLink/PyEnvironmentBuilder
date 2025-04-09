#!/usr/bin/env python3
"""
Tool for compiling iOS toolchain
================================

This tool intend to replace all the previous tools/ in shell script.
"""

import argparse
import platform
import sys
from sys import stdout
from os.path import join, dirname, realpath, exists, isdir, basename
from os import listdir, unlink, makedirs, environ, chdir, getcwd, walk
import sh
import subprocess
import zipfile
import tarfile
import importlib
import json
import shutil
import fnmatch
import tempfile
import time
from contextlib import suppress
from datetime import datetime
from pprint import pformat
import logging
import urllib.request
from pbxproj import XcodeProject
from pbxproj.pbxextensions.ProjectFiles import FileOptions

from pprint import pformat

url_opener = urllib.request.build_opener()
url_orig_headers = url_opener.addheaders
urllib.request.install_opener(url_opener)

curdir = dirname(__file__)

initial_working_directory = getcwd()

# For more detailed logging, use something like
# format='%(asctime)s,%(msecs)d %(levelname)-8s [%(filename)s:%(funcName)s():%(lineno)d] %(message)s'
logging.basicConfig(
    filename="log_output.log",
    format='[%(levelname)-8s] %(message)s',
    datefmt='%Y-%m-%d:%H:%M:%S',
    level=logging.INFO
)


# Quiet the loggers we don't care about
sh_logging = logging.getLogger('sh')
sh_logging.setLevel(logging.WARNING)

logger = logging.getLogger(__name__)

logger.info("new run:\n")

cmd_logger = logging.getLogger("cmd_log")
cmd_logger.setLevel(logging.INFO)
cmd_fh = logging.FileHandler("command_dump.log")
cmd_fh.setLevel(logging.INFO)
cmd_logger.addHandler(cmd_fh)

dump_hash_spaces = "#"*48




    

def shprint(command, *args, **kwargs):
    kwargs["_iter"] = True
    kwargs["_out_bufsize"] = 1
    kwargs["_err_to_out"] = True
    print(args)
    command(*args, **kwargs)
    
    
    




class ToolchainCL:
    
    cython: str | None
    
    
    def __init__(self):
        
        self.cython = None
        
        parser = argparse.ArgumentParser(
                description="Tool for managing the iOS / Python toolchain",
                usage="""toolchain <command> [<args>]
### modded ###
""")
        
        parser.add_argument("command", help="Command to run")
        args = parser.parse_args(sys.argv[1:2])
        if not hasattr(self, args.command):
            print('Unrecognized command')
            parser.print_help()
            exit(1)

        
        getattr(self, args.command)()
        

    def cythonize_folder(self):
        parser = argparse.ArgumentParser(
                description="Build the toolchain")
        parser.add_argument("folder", type=str, help="folder to cythonize")
        parser.add_argument("--root", type=str, nargs=1, default=None,
                            help="folder root")
        args = parser.parse_args(sys.argv[2:])
        
        #root: str | None = None
        
        
        # if args.root:
        #     root = args.root
        print(environ)
            
        root_dir = args.folder
        self.build_dir = root_dir
        #chdir(root_dir)
        self.resolve_cython()
        for root, dirnames, filenames in walk(root_dir):
            for filename in fnmatch.filter(filenames, "*.pyx"):
                print(filename)
                self.cythonize_file(join(root, filename))
            
    def cythonize_file(self, filename):
        
        
        if filename.startswith(self.build_dir):
            filename = filename[len(self.build_dir) + 1:]
        #logger.info("Cythonize {}".format(filename))
        # note when kivy-ios package installed the `cythonize.py` script
        # doesn't (yet) have the executable bit hence we explicitly call it
        # with the Python interpreter
        cythonize_script = "/Volumes/CodeSSD/py_env_playground/tools/cythonize.py"#join(self.ctx.root_dir, "tools", "cythonize.py")
        #shprint(sh.Command(sys.executable), cythonize_script, filename)
        if self.cython:
            self.do(filename)

    def resolve_cython(self):
        for executable in ('cython', 'cython-2.7'):
            for path in environ['PATH'].split(':'):
                if not exists(path):
                    continue
                if executable in listdir(path):
                    self.cython = join(path, executable)
                    return

    def do(self, fn: str):
        print('cythonize:', fn)
        assert fn.endswith('.pyx')
        parts = fn.split('/')
        if parts[0] == '.':
            parts.pop(0)
        modname = parts[-1][:-4]
        package = '_'.join(parts[:-1])

        # cythonize
        subprocess.Popen([self.cython, fn], env=environ).communicate()

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
            


def main():
    ToolchainCL()


if __name__ == "__main__":
    main()
