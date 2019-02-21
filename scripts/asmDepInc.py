#!/usr/bin/python3
# 
# Copyright (c) 2019 Andreas Zschunke
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 


import re
import sys
import argparse


class AsmParse:
  def __init__(self, asmFile, objFile, depFile, incFile, incDir):
    self.asmFile=asmFile
    self.objFile=objFile
    self.depFile=depFile
    self.incFile=incFile
    self.incDir=incDir

    self.includeMatch=re.compile('^\s*\.include\s+"([^"]+)"')
    self.statusText=re.compile('^\s*statusText\s+([^,]+),(.*)')
    self.exportMatch=re.compile('^\s*\.export\s+(\S+)')
    self.exportzpMatch=re.compile('^\s*\.exportzp\s+(\S+)')
    self.incBeginMatch=re.compile('^\s*;\s*incBegin')
    self.incEndMatch=re.compile('^\s*;\s*incEnd')
    self.macroBegin=re.compile('^\s*\.macro')
    self.macroEnd=re.compile('^\s*\.endmacro')

  def readInc(self, incFile):
    try:
      inc=open(self.incDir + '/' + incFile, 'r')

      for line in inc:
        m=self.includeMatch.match(line)
        if m:
          self.dep.write(self.objFile + ': ' + m.group(1) + '\n')
          self.dep.write(self.depFile + ': ' + m.group(1) + '\n')
          readInc(m.group(1))
      inc.close()
    except:
      pass

  def parseAsm(self):
    include=""
    incEnabled=False
    macro=False

    self.dep=open(self.depFile,'w')

    asm=open(self.asmFile, 'r')
    for line in asm:
      m=self.includeMatch.match(line)
      if m:
        if m.group(1) != 'c64.inc':
          self.dep.write(self.objFile + ': ' + m.group(1) + '\n')
          self.dep.write(self.depFile + ': ' + m.group(1) + '\n')
          self.readInc(m.group(1))

      if self.macroBegin.match(line):
        macro=True
      if self.macroEnd.match(line):
        macro=False

      if not macro:
        m=self.statusText.match(line)
        if m:
          include+=".import " + m.group(1) + "\n"
          for i in range(m.group(2).count(',')):
            include+=".import %s%d\n" % (m.group(1),i+1)
        m=self.exportMatch.match(line)
        if m:
          include+=".import " + m.group(1) + "\n"

        m=self.exportzpMatch.match(line)
        if m:
          include+=".importzp " + m.group(1) + "\n"


      if self.incEndMatch.match(line):
        incEnabled=False

      if incEnabled:
        include += line

      if self.incBeginMatch.match(line):
        incEnabled=True

    asm.close()
    self.dep.close()

    try:
      inc=open(self.incFile, 'r')
      incOld=inc.read()
      inc.close()
    except:
      incOld=""

    if include != incOld:
      inc=open(self.incFile, 'w')
      inc.write(include)
      inc.close()



p=argparse.ArgumentParser(description='create make file dependcies and include file for export from ca65 assembler file.')
p.add_argument('asmFile')
p.add_argument('objFile')
p.add_argument('depFile')
p.add_argument('incFile')
p.add_argument('incDir')
args = p.parse_args()

parseAsm=AsmParse(args.asmFile, args.objFile, args.depFile, args.incFile, args.incDir)
parseAsm.parseAsm()
