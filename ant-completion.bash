#!bash
#
#  Copyright (C) 2012 bjarneh
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------
#
#  Autocomplete for ant (original script in Ubuntu 12.04 does not work)
#  
#  Author      :  bjarneh@ifi.uio.no
#  Version     :  1.0
#  License     :  GPLv3
#  Depedencies :  python, coreutils, bash
#

#  Put this file somewhere it get's sourced (or source it yourself)
#  for instance put this file in $HOME/.bash_completion.d/
#  put this in $HOME/.profile
#  
#  if [ -d "${HOME}/.bash_completion.d" ]; then
#      for f in "$HOME/.bash_completion.d"/*;
#      do
#          . "$f"
#      done
#  fi
#  


_ant(){

    local prev cur flags targets xmls

    COMPREPLY=()

    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cur="${COMP_WORDS[COMP_CWORD]}"
    xmls=$(ls *.xml 2>/dev/null)
    flags="-help -h -projecthelp -p -version -diagnostics -quiet -q -verbose -v -debug -d -emacs -e -lib -logfile -logger -listener -noinput -buildfile -file -f -D -keep-going -k -propertyfile -inputhandler -find -s -nice -nouserlib -noclasspath -autoproxy -main"


    if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "${flags}" -- "${cur}") )
        return 0
    fi

    case "${prev}" in '-f'|'-file'|'-buildfile')
        COMPREPLY=( $(compgen -W "${xmls}" -- "${cur}"))
        return 0
        ;;
    esac

    if [[ "${prev}" == *.xml ]]; then
        targets=$(run_python "$prev")
        COMPREPLY=( $(compgen -W "${targets}" -- "${cur}") )
        return 0
    else
        if [ -f "build.xml" ]; then
            targets=$(run_python 'build.xml')
            COMPREPLY=( $(compgen -W "${targets}" -- "${cur}") )
            return 0
        fi
    fi

}

complete -o default -F _ant ant


# Inline Python in Bash (more readable then JSP and Tcl)
function run_python(){

python <<EOF
# -*- coding: utf-8 -*-

import os
import sys
import xml.sax.handler


class TargetHandler(xml.sax.handler.ContentHandler):
    """ fetch target names and import files from ant scripts"""
    def __init__(self):
        self.targets = []
        self.imports = []

    def startElement(self, name, attr):
        if name == 'target':
            targetName = attr.get('name')
            if targetName:
                self.targets.append(targetName)
        if name == 'import':
            importFile = attr.get('file')
            if importFile:
                self.imports.append(importFile)


def parseBuildXML(fname):
    """ fetch imports and target names using TargetHandler"""
    if os.path.isfile(fname):
        parser  = xml.sax.make_parser()
        handler = TargetHandler()
        parser.setContentHandler( handler )
        parser.parse(fname)
        return handler.targets, handler.imports, os.path.dirname(fname)
    else:
        return [],[],None
        

def recursiveBuildXML(dname, fname):
    """ find all targets in fname + all subtargets in imports of fname"""
    targets, files, dirname = parseBuildXML( os.path.join(dname, fname) )
    if files:
        subdir = dname
        if dirname:
            subdir = os.path.join(dname, dirname)
        for f in files:
            targets += recursiveBuildXML(subdir, f)
    return targets
        

def main(buildfile='./build.xml'):

    dname = os.path.dirname(buildfile)
    fname = os.path.basename(buildfile)

    targets = recursiveBuildXML( dname, fname )

    if targets:
        sys.stdout.write(' '.join( targets ))

if __name__ == '__main__':
    try:
        main("$1")
    except:
        pass
EOF

}
