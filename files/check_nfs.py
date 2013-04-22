#!/usr/bin/env python
import sys
import os
import subprocess
import signal
import pwd
import signal
import re
import argparse

TIMEOUT=5
MOUNT='/bin/mount'
DF='/bin/df'
LOGFILE='/var/log/kern.log'
OFFSET='/tmp/.message.offset1'
ERROR_STR='not responding, still trying'
UNKNOWN = -1
OK = 0
WARNING = 1
CRITICAL = 2

class Alarm(Exception):
    pass


def usage():
    print "Usage: " + sys.argv[0] + " -m for mountpoint only , -a for mountpoint and log"
    sys.exit(0)


def _arg_usage():
    parser = argparse.ArgumentParser(prog='Check nfs')
    parser.add_argument('-a',const='a',nargs='?',help='check nfs mountpoints and logs errors')
    parser.add_argument('-m',const='m',nargs='?',help='check nfs mountpoints only')

    args= parser.parse_args()
    if args.a=='a' or args.m=='m':
        return args
    else:
        parser.print_help()


def handler(signum,frame):
        raise Alarm()


def check_mount():
    list_fstab=[]
    n = subprocess.Popen(MOUNT,shell=False,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for x in n.communicate()[0].strip().splitlines():
        if re.search('nfs',x):
            x=x.split('on',1)[1]
            list_fstab.append(x.split('type',1)[0].split())
            
    if len(list_fstab)!=0:
        for _n in list_fstab:
            directory="".join(_n)
            p = subprocess.Popen([DF,"-k",directory],shell=False,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            signal.signal(signal.SIGALRM,handler)
            signal.alarm(5)
            try:
                errorMsg = p.communicate()[1].strip()
                signal.alarm(0)
            except Alarm:
                state=2
                msg="Mounted directory %s is not responding" % _n
                return state,msg
            ret=p.poll()
        if ret!=0:
            state=2
            msg="Mount not returning status"
            return state,msg
        else:  
            state=0
            msg="NFS Mount OK"
            return state,msg

    else:
        state=2
        msg="The mounted directory,not found!"  
        return state,msg


def check_Log():
    state='OK'
    errorMsg=0
    _out_ino=0
    _out_size=0
    
    if not os.path.isfile(OFFSET):
        f=open(OFFSET,'w')
        f.write(str(_out_ino)+"\n")
        f.write(str(_out_size)+"\n")
        f.close()
    else:
        f=open(OFFSET,'r')
        _out_ino=int(f.readline().strip())
        _out_size=int(f.readline().strip())
        f.close()
        
    e=open(LOGFILE,'r')
    out_ino=os.stat(LOGFILE).st_ino
    out_size=os.stat(LOGFILE).st_size

    if _out_ino!=out_ino or _out_size > out_size:
        _out_size=0
    e.seek(_out_size,0)
    if ERROR_STR in e.read():
        errorMsg=1
        
    out_size=e.tell()
    e.close()
    f=open(OFFSET,'w')
    f.write(str(out_ino)+"\n")
    f.write(str(out_size)+"\n")
    f.close()



    if errorMsg==1:
        state=2
        msg="NFS Error logged detected!"
    else:
        state=0
        msg="NFS Log OK"

    return state,msg



##############################
if __name__ == '__main__':

    try:
        if _arg_usage().m=='m':
            args=check_mount()
            if args[0]==0:
                print 'OK - %s' % args[1]
                raise SystemExit,OK
            if args[0]==2:
                print 'CRITICAL -%s' % args[1]
                raise SystemExit,CRITICAL
        else:
            margs=check_mount()
            largs=check_Log()
            if margs[0]==0 and largs[0]==0:
                print 'OK - %s : %s' % (margs[1],largs[1])
                raise SystemExit,OK
            else:
                #Raise Everything else as critical if NFS returns other than   0
                print 'CRITICAL - %s : %s' % (margs[1],largs[1])
                raise SystemExit,CRITICAL
    except Exception:
        raise SystemExit,CRITICAL

