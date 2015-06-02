#select surcharge, tolls_amount and total_amount colums from all csv files and input in a txtfile

for f in /home/data/NYCTaxis/trip_fare*.csv ; do
	awk -F ',' 'FNR > 1 {print $7"\t"$10"\t"$11}' $f >> /home/han91/
	tapdata.txt;
done

#Recalculate time
# First subtract pickuptime and dropofftime

for f in /home/data/NYCTaxis/trip_data*.csv ; do
	awk -F ',' 'FNR > 1' {print $6"\t"$7} >> /home/han91/time.txt ;
done

# Convert convert 00:20:40.28 (HH:MM:SS) to seconds in pickup columns

awk -F '\t' {print $1} /home/han91/time.txt | cut -d ' ' -f 2 |
 awk -F ':' '{ print ($1 * 3600) + ($2 * 60) + $3 }' > pickup.txt
 
 
# Convert convert 00:20:40.28 (HH:MM:SS) to seconds in dropoff columns

awk -F '\t' {print $2} /home/han91/time.txt | cut -d ' ' -f 2 |
 awk -F ':' '{ print ($1 * 3600) + ($2 * 60) + $3 }' > drop.txt
 
 # Paste pickup.txt and drop.txt
 
 paste -d '\t' pickup.txt drop.txt > timeseconds.txt
 
 # Subtract pickup from drop.txt
 
 awk -F '\t' '{print $2 - $1}' timeseconds.txt > triptime.txt
 
 #Now we should handle corner situation. For example, a man take taxi at 23:00:00
 and dropoff at tommorow daybreak 3:00:00. The time should be 24*3600 - 23*3600+ 3*3600.
 So the next code we modify the wrong time in diff.txt

# First Subset the day(00-31) in dropofftime

awk -F '\t' {print $2} /home/han91/retime/txt | cut -d ' ' -f 1 |
 cut -d '-' -f 3 > /home/han91/dropday.txt

# Subset the day(00-31) in pickuptime

awk -F '\t' {print $1} /home/han91/retime/txt | cut -d ' ' -f 1 |
 cut -d '-' -f 3 > /home/han91/pickupday.txt
 
# Paste pickupdat.txt and dropdat.txt

paste -d '\t' pickupday.txt dropday.txt > day.txt

# subtract the two day

awk -F "\t" '{print $2 -$1}' /home/han91/day.txt > /home/han91/
daysubtract.txt

#paste two files

paste -d '\t' triptime.txt daysubtract.txt > timewithday.txt

# If drop day is larger than pickup day, we add 24*3600=86400 to the first colums which is
time in seconds; else, we print the original time.

awk -F '\t' '{if($2 == 1){print $1 + 86400}else{print $1}}' timewithday.txt > 
finaltime.txt


#clean nrows whose tolls and totals are minus

#First paste tapdata.txt with finaltime.txt, tapdata contain
#surcharge, tolls_amount, total_amount

paste '\t' finaltime.txt tapdata.txt > dataframe.txt

#Select rows whose tolls_amount is greater than zero

awk -F '\t' '$3 >= 0 { print }' dataframe.txt > filtertolls.txt

#Select rows whose total_amount is greater than zero

awk -F '\t' '$4 >= 0 { print }' filtertolls.txt > filtertotal.txt

#Subtract tolls from total_amount

awk -F '\t' '{print $1"\t"$2"\t"$4 - $3}' filtertotal.txt > finalframe.txt

#Sperate each columns and save each in one txt file.

awk -F '\t' '{print $1}' finalframe.txt > ftime.txt

awk -F '\t' '{print $2}' finalframe.txt > fsurcharge.txt

awk -F '\t' '{print $3}' finalframe.txt > fdiff.txt










