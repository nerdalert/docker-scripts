#!/bin/sh

[ -z $1 ] && echo "Requires a tcp port number to lookup and match to a process\n  Usage: fproc <tcp_port>" && exit;
for pid in `fuser -n tcp $1|cut -d ":" -f 2`
do
  if ((parg==0)); then
  /bin/ps -p $pid -wwo  user,pid,args|head -n 1
  parg=1;
fi
/bin/ps -p $pid -wwo  user=,pid=,args=
done
unset parg;
