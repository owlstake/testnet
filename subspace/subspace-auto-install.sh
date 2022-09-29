#!/bin/bash
counter=0
CPUCORE=$(nproc)
readarray -t arrrewardaddress <rewardaddress.txt 2> /dev/null
arrlength=${#arrrewardaddress[@]}
if [[ arrlength -eq 0 ]]
then
        echo "plz add reward address on the file rewardaddress.txt"
        exit
fi
NODEQUANTITY=0
PORTARRAY=()
#########################
#Ask port ranges array
function ADDPORTARRAY {
PORTARRAY+=(4000)
PORTARRAY+=(5000)
PORTARRAY+=(6000)
}
##########################
function install {
cd $HOME/subspace-docker-folder
mkdir $counter
cd $counter
wget -O docker-compose.yaml https://raw.githubusercontent.com/owlstake/testnet/main/subspace/docker-compose.yaml
touch .env
ls -l
sudo tee $HOME/subspace-docker-folder/$counter/.env > /dev/null <<EOF
IMAGETAG=gemini-2a-2022-sep-10
NODENAME=owlstake$counter
PORT1=${PORTARRAY[0]}
PORT2=${PORTARRAY[1]}
PORT3=${PORTARRAY[2]}
REWARDADDRESS=${arrrewardaddress[$counter]}
PLOTSIZE=10G
EOF
############
PORTARRAY[0]=$((PORTARRAY[0]+1))
PORTARRAY[1]=$((PORTARRAY[1]+1))
PORTARRAY[2]=$((PORTARRAY[2]+1))
#docker compose up -d
#sleep 10
}
##########################
function start-install {
while [ $counter -lt $NODEQUANTITY ]
do
install
((counter++))
done
}
##########################
if [[ $CPUCORE -eq $arrlength ]]
then
echo "Number of CPU core is $CPUCORE"
echo "Number of reward address is $arrlength"
echo "Result: equal --> Starting to install the node"
###############################
# Start install function here
ADDPORTARRAY
rm -rf subspace-docker-folder
mkdir subspace-docker-folder
cd subspace-docker-folder
start-install
###############################
NODEQUANTITY=$CPUCORE
echo "We will install $NODEQUANTITY nodes"
elif [[ $CPUCORE -lt $arrlength ]]
then
echo "Number of CPU core is $CPUCORE"
echo "Number of reward address is $arrlength"
echo "Result: CPU core < reward address --> Starting to install the node based on number of CPU core"
NODEQUANTITY=$CPUCORE
echo "We will install $NODEQUANTITY nodes"
###############################
# Start install function here
ADDPORTARRAY
rm -rf subspace-docker-folder
mkdir subspace-docker-folder
cd subspace-docker-folder
start-install
###############################
elif [[ $CPUCORE -gt $arrlength ]]
then
echo "Number of CPU core is $CPUCORE"
echo "Number of reward address is $arrlength"
echo "Result: CPU core > reward address"
##### Ask question before doing
while true; do
read -p -r "Do you want to continue install the nodes based on number of reward address? (yes/no) " yn
case $yn in 
        yes ) echo ok, we will proceed;
                break;;
        no ) echo exiting...;
                exit;;
        * ) echo invalid response;;
esac
done
###############################
NODEQUANTITY=$arrlength
echo "We will install $NODEQUANTITY nodes"
###############################
# Start install function here
ADDPORTARRAY
rm -rf subspace-docker-folder
mkdir subspace-docker-folder
cd subspace-docker-folder
start-install
###############################
#####
fi
