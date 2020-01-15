#################################################################################
# Copyright (c) 2018 CGI. All rights reserved.
# Author  : Ajish Thomas
# Date    : 10 Oct 2018
# Purpose : Hogging thread check and thread-dump collector
#################################################################################

from java.util import *
from java.io import FileInputStream
from javax.management import *
import javax.management.Attribute
import sys, traceback
import time as tm
from java.lang import System
from time import sleep
import sys
import os

server_list=[]
thread_Dump_Dir='ThreadDumps'
PROPERTYFILE=sys.argv[1]
print("#  Reading inputs...")
loadProperties(PROPERTYFILE)
 

 
def hogger_servers():
 cd('/')
 domainRuntime()
 servers=domainRuntimeService.getServerRuntimes()
 f.write('\n\n'+serverName+':'+ds+' :Hogging thread check started ...')
 for server in servers:
  ser = server.getName()
  htc = server.getThreadPoolRuntime().getHoggingThreadCount() 
  f.write("\n"+ser+':'+ts+" :Hogging thread count is " +str(htc))
  if htc > 5 :
   f.write("\n Checking the hogging/stuck threads in "+ser)
   for thread in server.getThreadPoolRuntime().getExecuteThreads():
    if thread.isHogger() == 1 or thread.isStuck() == 1 :
     f.write("\n"+thread.getName() + " , " + str(thread.isHogger()) +" , " +repr(thread.getCurrentRequest()))
   thrdDumpServer(ser)  
  if htc > 9 :
   for number in range(4):
    f.write("\n Collecting threads consecutively: "+str(number))
    thrdDumpServer(ser)
    sleep(2)
  if htc >= 1 and htc < 5 :
   f.write("\nAny stuck threads in "+ser+ "...")
   for thread in server.getThreadPoolRuntime().getExecuteThreads():
    if thread.isStuck() == 1 :
     f.write("\n"+thread.getName() + " - " + str(thread.isHogger()))
     for number in range(4):
      f.write("\n Collecting threads consecutively: "+str(number))
      thrdDumpServer(ser)
      sleep(2)	
	
def thrdDumpAll():
 lt = tm.localtime(tm.time())
 ts = "%02d-%02d-%04d_%02d_%02d_%02d" % (lt[2], lt[1], lt[0], lt[3], lt[4], lt[5])
 domainRuntime()
 servers=domainRuntimeService.getServerRuntimes()	
 for name in servers:
  namOfServer = name.getName()
  printTimeStamp('Collecting threadDump  for server  ' + namOfServer)
  threadDump(fileName=thread_Dump_Dir+'/'+namOfServer+'_'+ts+'.txt',serverName=namOfServer)
 printTimeStamp('Thread dumps collected under '+thread_Dump_Dir)
 
def thrdDumpServer(value):
 lt = tm.localtime(tm.time())
 ds = "%02d-%02d-%04d" % (lt[2], lt[1], lt[0])
 ts = "%02d-%02d-%04d_%02d_%02d_%02d" % (lt[2], lt[1], lt[0], lt[3], lt[4], lt[5])
 ser_thread_Dump_Dir=thread_Dump_Dir+"/"+ds
 if not os.path.exists(ser_thread_Dump_Dir):
  os.makedirs(ser_thread_Dump_Dir)
 ser_thread_Dump_Dir=thread_Dump_Dir+"/"+ds
 f.write('\nCollecting threadDump  for server  ' + value)
 threadDump(fileName=ser_thread_Dump_Dir+'/'+value+'_'+ts+'.txt',serverName=value)
 f.write('Thread dumps collected in '+ser_thread_Dump_Dir+'/'+value+'_'+ts+'.txt')

lt = tm.localtime(tm.time())
ds = "%02d-%02d-%04d" % (lt[2], lt[1], lt[0])
ts = "%02d-%02d-%04d_%02d_%02d_%02d" % (lt[2], lt[1], lt[0], lt[3], lt[4], lt[5])
ser_thread_Dump_Dir=thread_Dump_Dir+"/"+ds
if not os.path.exists(thread_Dump_Dir):
 os.makedirs(thread_Dump_Dir)
if not os.path.exists(ser_thread_Dump_Dir):
 os.makedirs(ser_thread_Dump_Dir)
ser_thread_Dump_Dir=thread_Dump_Dir+"/"+ds
Hogging_thread_Check=ser_thread_Dump_Dir+'/Hogger_check'+ds+'.txt'
f = open(Hogging_thread_Check,"a+")


ADMIN_IP_PORT=ADMIN_IP_PORT.strip('"').split(',')
print ADMIN_IP_PORT
for oneAdminIP in ADMIN_IP_PORT :
 print(": Checking the Admin server > " +oneAdminIP)
 try:
  connect(USER,PASS,'t3://'+oneAdminIP)
 except:
  traceback.print_exc(file=sys.stdout)
  print "ERROR:Unable to find Admin server..."
 hogger_servers()
 disconnect() 



