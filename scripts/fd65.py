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

fileName=sys.argv[1]
symFileName=sys.argv[2]

f=open(symFileName, 'r')
lineMatch=re.compile('^al 00([0-9A-F][0-9A-F][0-9A-F][0-9A-F]) \.(\S+)')
labels={}
for l in f:
  m=lineMatch.match(l)
  if m:
    #print m.group(1), m.group(2)
    labels['L' + m.group(1)]=m.group(2)
f.close()


f=open(fileName, 'r')
labelAdjust=20
opcodeAdjust=32
lineMatch1=re.compile('^(L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]): *(.*)')
lineMatch2=re.compile('^ *(.*)(L[0-9A-F][0-9A-F][0-9A-F][0-9A-F])(\S*) *(.*)')
lineMatch3=re.compile('^ ')
#lineMatch4=re.compile('^\s*(\S*)\s+$([0-9A-F][0-9A-F])')
lineMatch4=re.compile('^\s*([^#]*)\$([0-9A-F][0-9A-F])([, )]\S*)\s*(.*)')
lineMatch5=re.compile('^\s*(.*)\$([0-9A-F][0-9A-F][0-9A-F][0-9A-F])([, )]\S*)\s*(.*)')
for l in f:
  m=lineMatch1.match(l)
  if m:
    if m.group(1) in labels:
      print ((labels[m.group(1)]+':').ljust(labelAdjust),end='')
    else:
      print ((m.group(1)+':').ljust(labelAdjust),end='')
    l=m.group(2)
  elif lineMatch3.match(l):
    print (' '.ljust(labelAdjust),end='')

  m=lineMatch2.match(l)
  if m:
    if m.group(2) in labels:
      print(m.group(1)+(labels[m.group(2)]+m.group(3)).ljust(opcodeAdjust)+m.group(4))
    else:
      print(m.group(1)+(m.group(2)+m.group(3)).ljust(opcodeAdjust)+m.group(4))
  else:
    m2=lineMatch4.match(l)
    if m2 and ("L00%s" % (m2.group(2))) in labels:
      print(m2.group(1)+(labels[("L00%s" % (m2.group(2)))]+m2.group(3)).ljust(opcodeAdjust)+m2.group(4))
      #print m.group(1)+(m.group(2)+m.group(3)).ljust(opcodeAdjust)+m.group(4)
    else:
      m2=lineMatch5.match(l)
      if m2 and ("L%s" % (m2.group(2))) in labels:
        print(m2.group(1)+(labels[("L%s" % (m2.group(2)))]+m2.group(3)).ljust(opcodeAdjust)+m2.group(4))
        #print m.group(1)+(m.group(2)+m.group(3)).ljust(opcodeAdjust)+m.group(4)
      else:
        print(l.strip())


f.close()

