#!/bin/bash
########################
# install docker
sudo apt update && sudo apt upgrade -y
sudo apt install curl build-essential git wget jq make gcc ack tmux ncdu -y
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.27.3/yq_linux_amd64 && chmod +x /usr/local/bin/yq
apt update && apt install git sudo unzip wget -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
########################
#install subkey to generate wallets
sudo apt install -y protobuf-compiler

#Rust and Cargo
curl https://sh.rustup.rs -sSf | sh

#install the dependencies and Subkey
#https://support.polkadot.network/support/solutions/articles/65000180519-how-to-create-an-account-in-subkey
curl https://getsubstrate.io -sSf | bash -s -- --fast
cargo install --force subkey --git https://github.com/paritytech/substrate

sleep 1

########################
#generate subsapce wallets
echo "Number of wallets: "
read noofwallet
x=1

#export all information of wallets (phrase, public address,...) to rewardaddress-phrases.txt file
while [ $x -le $noofwallet ]
do
  echo "account $x:"
  subkey generate -n subspace_testnet
  #echo -e "\n"
  x=$(( $x + 1 ))
done > rewardaddress-phrases.txt

#copy public address from rewardaddress-phrases.txt to rewardaddress.txt for next step
x=1
while [ $x -le $noofwallet ]
do
  #echo "account $x:"
  echo $(sed $((8*$x))'!d' rewardaddress-phrases.txt)
  #echo -e "\n"
  x=$(( $x + 1 ))
done > rewardaddress.txt

#replace all the things but public adress in rewardaddress.txt file
v1="SS58 Address:"
v2=" "
v3=""
sed -i "s/$v1/$v3/" rewardaddress.txt
sed -i "s/$v2/$v3/" rewardaddress.txt

########################
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
docker compose up -d
sleep 10
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
NODEQUANTITY=$CPUCORE
echo "We will install $NODEQUANTITY nodes"
ADDPORTARRAY
rm -rf subspace-docker-folder
mkdir subspace-docker-folder
cd subspace-docker-folder
start-install
###############################
elif [[ $CPUCORE -lt $arrlength ]]
then
echo "Number of CPU core is $CPUCORE"
echo "Number of reward address is $arrlength"
echo "Result: CPU core < reward address --> Starting to install the node based on number of CPU core"
###############################
# Start install function here
NODEQUANTITY=$CPUCORE
echo "We will install $NODEQUANTITY nodes"
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
# Start install function here
###############################
NODEQUANTITY=$arrlength
echo "We will install $NODEQUANTITY nodes"
ADDPORTARRAY
rm -rf subspace-docker-folder
mkdir subspace-docker-folder
cd subspace-docker-folder
start-install
###############################
#####
fi
echo "Result here"
docker ps
