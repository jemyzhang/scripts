#!/bin/bash  
# Get current swap usage for all running processes  
# writted by xly  
# modified by jemyzhang
  

function getswap {  
SUM=0  
OVERALL=0  
for DIR in `find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]"` ; do  
PID=`echo $DIR | cut -d / -f 3`  
PROGNAME=`ps -p $PID -o comm --no-headers`  
for SWAP in `grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'`  
do  
let SUM=$SUM+$SWAP  
done  
if [ $SUM -gt 0 ]; then
    echo "$PROGNAME $PID $SUM"  
    let OVERALL=$OVERALL+$SUM  
fi
SUM=0  
  
done  
echo "Overall - $OVERALL"
} 
 
getswap | awk 'NR>1' | sort -rnk3 | awk '
  BEGIN {printf "%-20s\tPID\tSIZE\n", "COMMAND"} 
  {
      size_in_bytes = $3 * 1024
      split("B KB MB GB TB PB", unit)
      human_readable = 0
      if (size_in_bytes == 0) {
          human_readable = 0
          j = 0
      } else {
          for (j = 5; human_readable < 1; j--)
              human_readable = size_in_bytes / (2^(10*j))
      }
    printf "%-20s\t%s\t%s%s\n", $1, $2, human_readable, unit[j+2]
  }
' | less
#getswap|egrep -v "Swap used: 0"
