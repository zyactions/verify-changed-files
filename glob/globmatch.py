#!/usr/bin/env python3
# coding: utf8

import argparse
import os
from pathlib import Path
import sys

# Enable relative import of `wcmatch`
sys.path.append('.')
from wcmatch import glob

parser = argparse.ArgumentParser(description='Reads from `stdin` and returns each line that matches the given glob pattern.')
parser.add_argument('pattern', nargs='+', help='The glob pattern to use. Can be passed multiple times.')
args = parser.parse_args()

# Ignore comments
patterns = list(filter(lambda x: not x.startswith('#'), args.pattern))

# Substitute '~' with the current user path
home = str(Path.home())
patterns = list(map(lambda x: os.path.join(home, x[1:]) if x.startswith('~') else x, patterns))

for line in sys.stdin:
    filename = line.rstrip()
    if glob.globmatch(filename, patterns=patterns, limit=100, flags=
        glob.NODOTDIR  |    # Do not match '.' and '..'
        glob.DOTGLOB   |    # Match directories and files that start with '.'
        glob.NEGATE    |    # A preceeding '!' negates the pattern
        glob.NEGATEALL |    # Assume '**' if no inlcusion pattern was passed
        glob.EXTGLOB   |    # Enable extended pattern list matching
        glob.GLOBSTAR  |    # Enable '**' pattern to match zero or more directories
        glob.BRACE          # Enable brace expansion 
    ):
        print(line, end='', flush=True)
