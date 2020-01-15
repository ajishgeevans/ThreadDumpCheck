#################################################################################
# Copyright (c) 2018 CGI. All rights reserved.
# Author  : Ajish Thomas
# Date    : 20 Oct 2018
# Purpose : Hogging thread check and thread-dump collector
#################################################################################


DAY=`date +"%d-%m-%Y"`
TD_DIR=ThreadDumps/$DAY
day=30

cleanup()
{
if [ -d ThreadDumps ] && [ ! -d "ThreadDumps/$DAY" ];then
   Size=`du -sk ThreadDumps | awk '$1/1000>200{print $2}'`
      if [ ! -z $Size ]; then
         echo "Cleaning ThreadDumps Dir ..."
         find ThreadDumps -type d -mtime +$day -exec rm -rf {} \;
      fi
fi
}



alertCheck()
{
DAY=`date +"%d-%m-%Y"`
TD_DIR=ThreadDumps/$DAY
cd $TD_DIR
[ ! -f .Temp_Hogger_check.txt ] && touch .Temp_Hogger_check.txt
hoggercheck=`diff Hogger_check${DAY}.txt .Temp_Hogger_check.txt |grep Hogging |awk '$7>2{print $2 " :" $7}'`
if [ ! -z $hoggercheck ]; then
   echo $hoggercheck
fi

for check in   $hoggercheck
do
 echo $check
done
cp  Hogger_check${DAY}.txt .Temp_Hogger_check.txt
 
}

cleanup
export PATH=$PATH:/omfd2/oracle/product/fmw11g/wlserver_10.3/common/bin/
wlst.sh hoggingThreadCheck.py OMF_WLSProperties.txt
