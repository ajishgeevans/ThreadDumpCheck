alertCheck()
{
TO_EMAIL="ajish.thomas@cgi.com"
DAY=`date +"%d-%m-%Y"`
TD_DIR=ThreadDumps/$DAY
if [ -d $TD_DIR ];
then
 cd $TD_DIR
 [ ! -f .Temp_Hogger_check.txt ] && touch .Temp_Hogger_check.txt
 hoggercheck=`diff Hogger_check${DAY}.txt .Temp_Hogger_check.txt |grep Hogging |awk '$7>5{print $2 ":" $7}'`
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
   echo "<html>"  >.TempHList
   echo "<body>" >>.TempHList
   echo "<b> ${tm1}:Thread details </b>" >>.TempHList
   echo " " >>.TempHList
   sed -n '/'$nd_tm'/,/'$nd_tm1'/p' Hogger_check${DAY}.txt | sed '/'$nd'/d' >>.TempHList
   echo "</body>" >> .TempHList
   echo "</html>" >>.TempHList
   zip -r ${nd_tm1}.zip $nd_tm1* >> /dev/null
   if [ -${nd_tm1}.zip ]; then
     echo "Sending a mail.." 
 	cat .TempHList |/home/athomas/sendEmail -q -u Alert:Hogging Thread:$nd:Count:$td -f omfhogger@omfdomain.com -t $TO_EMAIL -a ${nd_tm1}.zip
 	rm ${nd_tm1}.zip
   fi
 done
 cp  Hogger_check${DAY}.txt .Temp_Hogger_check.txt
fi
}

alertCheck
