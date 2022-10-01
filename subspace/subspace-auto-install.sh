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

########################
#install subkey to generate subsapce wallets

   sudo apt install -y protobuf-compiler

   #Rust and Cargo
   curl https://sh.rustup.rs -sSf | sh
   source "$HOME/.cargo/env"

   #install the dependencies and Subkey
   #https://support.polkadot.network/support/solutions/articles/65000180519-how-to-create-an-account-in-subkey
   curl https://getsubstrate.io -sSf | bash -s -- --fast
   source "$HOME/.cargo/env"

   cargo install --force subkey --git https://github.com/paritytech/substrate
   source "$HOME/.cargo/env"

   sleep 1 



########################
#generate subsapce wallets
cd $HOME
echo "Number of wallets: "
read noofwallet

#generate wallets and export all information of wallets (phrase, public address,...) to rewardaddress-phrases.txt file stored at $HOME
x=1
while [ $x -le $noofwallet ]
do
  echo "account $x:"
  subkey generate -n subspace_testnet
  #echo -e "\n"
  x=$(( $x + 1 ))
done > rewardaddress-phrases.txt

echo "All wallets stored at $HOME/rewardaddress-phrases.txt. Be sure to backup!!"

sleep 5

#file rewardaddress-phrases.txt be like this:

# account 1:
# Secret phrase:       vote toss warfare decorate chimney spend current debris emotion split turkey loop
#   Network ID:        subspace_testnet
#   Secret seed:       0x51498e59cac4e065165db7bd6712de77f25e7ed6fc7cef18bc0f7961125c8683
#   Public key (hex):  0x06bb263b7aef565701bf2a04a4217d3c552f9c676a1615d0f7dc4c889a61393c
#   Account ID:        0x06bb263b7aef565701bf2a04a4217d3c552f9c676a1615d0f7dc4c889a61393c
#   Public key (SS58): st6R1pLS5hjKbNsowAGHeaxdUpqwcF4jhTp6NSH9b6G66986q
#   SS58 Address:      st6R1pLS5hjKbNsowAGHeaxdUpqwcF4jhTp6NSH9b6G66986q
# account 2:
# Secret phrase:       remind obvious cruel rain pelican deny breeze junk coin fiction drop liberty
#   Network ID:        subspace_testnet
#   Secret seed:       0xb89aeb684bd08340f5c056076f30d93ee3da46ee31476f4a444f060156b1e29e
#   Public key (hex):  0x388d6b42bbfce8b8538114be43502888c21c40812bd7492851414cc28c07e56e
#   Account ID:        0x388d6b42bbfce8b8538114be43502888c21c40812bd7492851414cc28c07e56e
#   Public key (SS58): st7YLdHXbyYSuEHo7uewep8WCCyHQyokF8HpeqF9Qpb9ynoi9
#   SS58 Address:      st7YLdHXbyYSuEHo7uewep8WCCyHQyokF8HpeqF9Qpb9ynoi9
# account 3:
# Secret phrase:       embody movie anxiety labor crane speak excess face tongue adult mixed fresh
#   Network ID:        subspace_testnet
#   Secret seed:       0xb98edda590c01eb0c349d1402c959d508e3fa090c2c66dcc61a19e5787eb192a
#   Public key (hex):  0xe8b273a43fcfb8ec5ccb8ecf8422c69bd3acef472039078b9f7f78adc3733b4a
#   Account ID:        0xe8b273a43fcfb8ec5ccb8ecf8422c69bd3acef472039078b9f7f78adc3733b4a
#   Public key (SS58): stBXJ49mnYLzayGWjDyejSPuRp2vS4z9Wai8hmtfaaD8SivdH
#   SS58 Address:      stBXJ49mnYLzayGWjDyejSPuRp2vS4z9Wai8hmtfaaD8SivdH

########################

#copy public address from rewardaddress-phrases.txt to rewardaddress.txt for next steps
x=1
while [ $x -le $noofwallet ]
do
  #echo "account $x:"
  echo $(sed $((8*$x))'!d' rewardaddress-phrases.txt)
  #echo -e "\n"
  x=$(( $x + 1 ))
done > rewardaddress.txt

#file rewardaddress.txt be like this:

#    SS58 Address:      st6R1pLS5hjKbNsowAGHeaxdUpqwcF4jhTp6NSH9b6G66986q
#    SS58 Address:      st7YLdHXbyYSuEHo7uewep8WCCyHQyokF8HpeqF9Qpb9ynoi9
#    SS58 Address:      stBXJ49mnYLzayGWjDyejSPuRp2vS4z9Wai8hmtfaaD8SivdH

########################

#replace all the things but public adress in rewardaddress.txt file
v1="SS58 Address:"
v2=" "
v3=""
sed -i "s/$v1/$v3/" rewardaddress.txt
sed -i "s/$v2/$v3/" rewardaddress.txt

#file rewardaddress.txt now like this:

#st6R1pLS5hjKbNsowAGHeaxdUpqwcF4jhTp6NSH9b6G66986q
#st7YLdHXbyYSuEHo7uewep8WCCyHQyokF8HpeqF9Qpb9ynoi9
#stBXJ49mnYLzayGWjDyejSPuRp2vS4z9Wai8hmtfaaD8SivdH


sleep 1
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