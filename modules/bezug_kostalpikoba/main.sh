#!/bin/bash

#Auslesen eines Kostal Piko WR über die integrierte API des WR mit angeschlossenem Eigenverbrauchssensor.
#Ergänzt um diverse Variablen

pvwatttmp=$(curl --connect-timeout 3 -s $wrkostalpikoip/api/dxs.json?dxsEntries=67109120'&'dxsEntries=251658753'&'dxsEntries=83887106'&'dxsEntries=83887362'&'dxsEntries=83887618'&'dxsEntries=67109378'&'dxsEntries=67109634'&'dxsEntries=67109890'&'dxsEntries=67109379'&'dxsEntries=67109635'&'dxsEntries=67109891)
#Erklärung der dxsEntries
#0:  67109120	Über alle drei Phasen summierte Ausgangsleistung des Wechselrichters
#1:  251658753 	Gesamtertrag Wechselrichter
#2:  83887106	Hausverbrauch L1
#3:  83887362	Hausverbrauch L2
#4:  83887618	Hausverbrauch L3
#5:  67109378	Spannung L1
#6:  67109634	Spannung L2
#7:  67109890	Spannung L3
#8:  67109379	WR-Ausgangsleistung L1
#9:  67109635	WR-Ausgangsleistung L2
#10: 67109891	WR-Ausgangsleistung L3

#aktuelle Ausgangsleistung am WR [W]
wrausgang=$(echo $pvwatttmp | jq '.dxsEntries[0].value' | sed 's/\..*$//')
speicherleistung=$(</var/www/html/openWB/ramdisk/speicherleistung)
pvwatt=$(echo "$wrausgang+$speicherleistung" |bc)
#pvwatt wird jetzt aus der Ausgangsleistung des WR berechnet, somit spielt WR-Wirkungsgrad keine Rolle (zumindest im PV-Betrieb)

if [ $pvwatt > 5 ]
	 then
	  pvwatt=$(echo "$pvwatt*-1" |bc)
fi   

#zur weiteren verwendung im webinterface
echo $pvwatt > /var/www/html/openWB/ramdisk/pvwatt
#Gesamtzählerstand am WR [kWh]
pvkwh=$(echo $pvwatttmp | jq '.dxsEntries[1].value' | sed 's/\..*$//')
pvkwh=$(echo "$pvkwh*1000" |bc)
#zur weiteren verwendung im webinterface	
echo $pvkwh > /var/www/html/openWB/ramdisk/pvkwh

#Bei Verwendung des Sensors auf der Bezugsseite (Modus 1 laut Benutzerhandbuch) zeigt dieser den Eigenverbrauch an. Der Netzbezug muss daher separat berechnet werden.

eigenvbw1=$(echo $pvwatttmp | jq '.dxsEntries[2].value' | sed 's/\..*$//')
eigenvbw2=$(echo $pvwatttmp | jq '.dxsEntries[3].value' | sed 's/\..*$//')
eigenvbw3=$(echo $pvwatttmp | jq '.dxsEntries[4].value' | sed 's/\..*$//')

wrausgangw1=$(echo $pvwatttmp | jq '.dxsEntries[8].value' | sed 's/\..*$//')
wrausgangw2=$(echo $pvwatttmp | jq '.dxsEntries[9].value' | sed 's/\..*$//')
wrausgangw3=$(echo $pvwatttmp | jq '.dxsEntries[10].value' | sed 's/\..*$//')

bezugw1=$(echo "$eigenvbw1-$wrausgangw1" |bc)
bezugw2=$(echo "$eigenvbw2-$wrausgangw2" |bc)
bezugw3=$(echo "$eigenvbw3-$wrausgangw3" |bc)

evuv1=$(echo $pvwatttmp | jq '.dxsEntries[5].value' | sed 's/\..*$//')
evuv2=$(echo $pvwatttmp | jq '.dxsEntries[6].value' | sed 's/\..*$//')
evuv3=$(echo $pvwatttmp | jq '.dxsEntries[7].value' | sed 's/\..*$//')

if [[ "$speichermodul" == "speicher_bydhv" ]]; then
	speicherleistung=$(</var/www/html/openWB/ramdisk/speicherleistung)
	# wattbezug=$(echo "$bezugw1+$bezugw2+$bezugw3+$pvwatt+$speicherleistung" | bc) 
	wattbezug=$(echo "$bezugw1+$bezugw2+$bezugw3" | bc) 
else
	wattbezug=$(echo "$bezugw1+$bezugw2+$bezugw3" |bc)
fi


echo $wattbezug
echo $wattbezug > /var/www/html/openWB/ramdisk/wattbezug
bezuga1=$(echo "scale=2 ; $bezugw1 / $evuv1" | bc)
bezuga2=$(echo "scale=2 ; $bezugw2 / $evuv2" | bc)
bezuga3=$(echo "scale=2 ; $bezugw3 / $evuv3" | bc)
echo $bezugw1 > /var/www/html/openWB/ramdisk/bezugw1
echo $bezugw2 > /var/www/html/openWB/ramdisk/bezugw2
echo $bezugw3 > /var/www/html/openWB/ramdisk/bezugw3
echo $bezuga1 > /var/www/html/openWB/ramdisk/bezuga1
echo $bezuga2 > /var/www/html/openWB/ramdisk/bezuga2
echo $bezuga3 > /var/www/html/openWB/ramdisk/bezuga3
echo $evuv1 > /var/www/html/openWB/ramdisk/evuv1
echo $evuv2 > /var/www/html/openWB/ramdisk/evuv2
echo $evuv3 > /var/www/html/openWB/ramdisk/evuv3



# #!/bin/bash

# #Auslesen eines Kostal Piko WR über die integrierte API des WR mit angeschlossenem Eigenverbrauchssensor.

# pvwatttmp=$(curl --connect-timeout 3 -s $wrkostalpikoip/api/dxs.json?dxsEntries=33556736'&'dxsEntries=251658753'&'dxsEntries=83887106'&'dxsEntries=83887362'&'dxsEntries=83887618'&'dxsEntries=67109378'&'dxsEntries=67109634'&'dxsEntries=67109890)

# #aktuelle Ausgangsleistung am WR [W]
# pvwatt=$(echo $pvwatttmp | jq '.dxsEntries[0].value' | sed 's/\..*$//')

# if [ $pvwatt > 5 ]
	 # then
	  # pvwatt=$(echo "$pvwatt*-1" |bc)
# fi   

# #zur weiteren verwendung im webinterface
# echo $pvwatt > /var/www/html/openWB/ramdisk/pvwatt
# #Gesamtzählerstand am WR [kWh]
# pvkwh=$(echo $pvwatttmp | jq '.dxsEntries[1].value' | sed 's/\..*$//')
# pvkwh=$(echo "$pvkwh*1000" |bc)
# #zur weiteren verwendung im webinterface	
# echo $pvkwh > /var/www/html/openWB/ramdisk/pvkwh

# bezugw1=$(echo $pvwatttmp | jq '.dxsEntries[2].value' | sed 's/\..*$//')
# bezugw2=$(echo $pvwatttmp | jq '.dxsEntries[3].value' | sed 's/\..*$//')
# bezugw3=$(echo $pvwatttmp | jq '.dxsEntries[4].value' | sed 's/\..*$//')

# evuv1=$(echo $pvwatttmp | jq '.dxsEntries[5].value' | sed 's/\..*$//')
# evuv2=$(echo $pvwatttmp | jq '.dxsEntries[6].value' | sed 's/\..*$//')
# evuv3=$(echo $pvwatttmp | jq '.dxsEntries[7].value' | sed 's/\..*$//')
# if [[ "$speichermodul" == "speicher_bydhv" ]]; then
	# speicherleistung=$(</var/www/html/openWB/ramdisk/speicherleistung)
	# wattbezug=$(echo "$bezugw1+$bezugw2+$bezugw3+$pvwatt+$speicherleistung" | bc) 
# else
	# wattbezug=$(echo "$bezugw1+$bezugw2+$bezugw3+$pvwatt" |bc)
# fi


# echo $wattbezug
# echo $wattbezug > /var/www/html/openWB/ramdisk/wattbezug
# bezuga1=$(echo "scale=2 ; $bezugw1 / $evuv1" | bc)
# bezuga2=$(echo "scale=2 ; $bezugw2 / $evuv2" | bc)
# bezuga3=$(echo "scale=2 ; $bezugw3 / $evuv3" | bc)
# echo $bezuga1 > /var/www/html/openWB/ramdisk/bezuga1
# echo $bezuga2 > /var/www/html/openWB/ramdisk/bezuga2
# echo $bezuga3 > /var/www/html/openWB/ramdisk/bezuga3
# echo $evuv1 > /var/www/html/openWB/ramdisk/evuv1
# echo $evuv2 > /var/www/html/openWB/ramdisk/evuv2
# echo $evuv3 > /var/www/html/openWB/ramdisk/evuv3





