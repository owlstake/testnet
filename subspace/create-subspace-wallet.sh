#!/bin/bash
#################################
# check subkey installed or not
pkg='subkey'
which $pkg > /dev/null 2>&1
if [ $? == 0 ]
then
        echo "$pkg is already installed. "
else
wget -O subkey https://raw.githubusercontent.com/owlstake/testnet/main/subspace/subkey
chmod +x subkey
mv subkey /usr/bin/
subkey --version
fi
##################################
#### backup current keys if exist
FILE1=$HOME/backupkey.txt
FILE2=$HOME/rewardaddress.txt
if test -f "$FILE1"; then
    echo "$FILE1 exists."
    mv $FILE1 $FILE1.$(date +'%m-%d-%Y-%H-%M-%S')
    echo "Renamed the old backupkey file"
fi
if test -f "$FILE2"; then
    echo "$FILE2 exists."
    mv $FILE2 $FILE2.$(date +'%m-%d-%Y-%H-%M-%S')
     echo "Renamed the old rewardaddress file"
fi
##################################
#### Ask the number of reward address
echo "If your CPU have 8 cores then fill this value with 8"
read -p "Enter your address do you want to create : " loopnumber
if ! [[ "$loopnumber" =~ ^[0-9]+$ ]] || [[ $loopnumber -eq 0 ]] ;
 then exec >&2; echo "error: Not a number"; exit 1
fi
for (( i=1 ; i<=$loopnumber ; i++ ));
do
    #echo $i
    subkey generate -n subspace_testnet >> $FILE1
done
if test -f "$FILE1"; then
    #echo "$FILE1 exists."
    grep 'SS58 Address:' $FILE1 | sed 's/^.*: //' | sed -r 's/\s+//g' >> $FILE2
fi
cat $FILE2
