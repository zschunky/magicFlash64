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


from ftplib import FTP
import sys
import os

ftp=FTP(sys.argv[1])
print('login:', ftp.login())
print('cwd:', ftp.cwd(sys.argv[2]))
for f in (sys.argv[3:]):
  try:
    print('delete "%s":' % (os.path.basename(f)),ftp.delete(os.path.basename(f)))
  except:
    pass


for f in (sys.argv[3:]):
  while True:
    try:
      print('store "%s":' % (f), ftp.storbinary('STOR %s' % (os.path.basename(f)), open(f,'rb')))
    except:
      print('store error "%s"' % (f))
      continue
    break



print('quit:',ftp.quit())
