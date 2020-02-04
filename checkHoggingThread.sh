#################################################################################
# Copyright (c) 2018 CGI. All rights reserved.
# Author  : Ajish Thomas
# Date    : 20 Oct 2018
# Modified: 28 Aug 2019
# Purpose : Hogging thread check and thread-dump collector
#################################################################################

TO_EMAIL="ajish.thomas@cgi.com,sumit.srivastava@cgi.com,nalini.kanthareddy@cgi.com,sundeep.gotru@cgi.com,abhishek.medum@cgi.com,JT2.IGDC.BAN.INDIA@cgi.com"
#TO_EMAIL="ajish.thomas@cgi.com"

DAY=`date +"%d-%m-%Y"`
TD_DIR=ThreadDumps/$DAY
day=30

cleanup()
{
if [ -d ThreadDumps ] && [ ! -d "ThreadDumps/$DAY" ];then
   Size=`du -sk ThreadDumps | awk '$1/1000>500{print $2}'`
      if [ ! -z $Size ]; then
         echo "Cleaning ThreadDumps Dir ..."
         find ThreadDumps -type d -mtime +$day -exec rm -rf {} \;
      fi
fi
}
alertCheck()
{
if [ -d $TD_DIR ];
then
 cd $TD_DIR
 [ ! -f .Temp_Hogger_check.txt ] && touch .Temp_Hogger_check.txt
 hoggercheck=`diff Hogger_check${DAY}.txt .Temp_Hogger_check.txt |grep Hogging |awk '$7>9{print $2 ":" $7}'`
 if [ ! -z "$hoggercheck" ]; then
    echo $hoggercheck
 fi	
 for check in   $hoggercheck
 do
   nd=`echo $check |cut -d: -f1`
   td=`echo $check |cut -d: -f3`
   tm=`echo $check |cut -d: -f2`
   tm1=`echo $tm |cut -d_ -f1,2,3`
   nd_tm="${nd}":"${tm}"
   nd_tm1="${nd}"_"${tm1}"
   echo $td
   echo "${tm1}:Hogger Thread Info" >.TempHList
   echo " " >>.TempHList
   sed -n '/'$nd_tm'/,/Collecting/p' Hogger_check${DAY}.txt | grep '^\[' |  awk '{print $1 $2 $3 ","$17" " $18$19"ms ," $21}' >>.TempHList
   echo " " >>.TempHList
#*************** Thead stack details
   echo "Thread stack info.." >>.TempHList
   tFile=`ls -1 $nd_tm1* |head -1`
   tList=`sed -n '/'$nd_tm'/,/Collecting/p' Hogger_check${DAY}.txt | grep '^\[' |awk '{print $2 "-" $3}'`
   if [ -f "$tFile" ] && [ ! -z "$tList" ]; then
    for tID in $tList
    do
     tID=`echo $tID |tr - " "`
     echo ">>>" >>.TempHList
     cat $tFile |grep -A 8 "$tID"  |head -8 >>.TempHList
    done
   fi
#*************** Thead stack details
   echo " " >>.TempHList
   echo "Hogger thread >10 in a day " >>.TempHList
   echo " " >>.TempHList
   cat Hogger_check${DAY}.txt |grep "Hogging" |awk '$6>10{print $1 " " $6}' >>.TempHList
   zip -r ${nd_tm1}.zip $nd_tm1* >> /dev/null
   if [ -${nd_tm1}.zip ]; then
     echo "Sending a mail.." 
 	cat .TempHList |/home/athomas/sendEmail -q -u Alert:Hogging Thread:$nd:Count:$td -f hogger@omfdomain.com -t $TO_EMAIL -a ${nd_tm1}.zip
 	rm ${nd_tm1}.zip
   fi
done
 cp  Hogger_check${DAY}.txt .Temp_Hogger_check.txt
fi

}

export PATH=$PATH:/omf/oracle/product/fmw11g/wlserver_10.3/common/bin/
cleanup
wlst.sh  hoggingThreadCheck.py OMF_WLSProperties.txt
alertCheck

