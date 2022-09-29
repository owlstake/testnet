## Guide
###### Install docker and other support software
```
#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl build-essential git wget jq make gcc ack tmux ncdu -y
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.27.3/yq_linux_amd64 && chmod +x /usr/local/bin/yq
apt update && apt install git sudo unzip wget -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
### Auto Install
```
wget -O subspace-auto-install.sh https://raw.githubusercontent.com/owlstake/testnet/main/subspace/subspace-auto-install.sh
chmod +x subspace-auto-install.sh

# You need to create rewardaddress.txt first
# you need to find your CPU core and RAM
# 1 node need 1 CPU core, 2GB RAM and 10GB SSD, DYOR
# If you have 8 CPUs, 16GB RAM, 100GB SSD then add 8 reward addresses

touch rewardaddress.txt
nano rewardaddress.txt

# And then add your reward address on each line

# Example
cat rewardaddress.txt
st8xB6NyihB8N5becPpB4YiXXoASJgqPKedXXMHKwFPev4M51
st8xB6NyihB8N5becPpB4YiXXoASJgqPKedXXMHKwFPev4M52
st8xB6NyihB8N5becPpB4YiXXoASJgqPKedXXMHKwFPev4M53
st8xB6NyihB8N5becPpB4YiXXoASJgqPKedXXMHKwFPev4M54
st8xB6NyihB8N5becPpB4YiXXoASJgqPKedXXMHKwFPev4M65
st8xB6NyihB8N5becPpB4YiXXoASJgqPKedXXMHKwFPev4M56
st8xB6NyihB8N5becPpB4YiXXoASJgqPKedXXMHKwFPev4M57
st8xB6NyihB8N5becPpB4YiXXoASJgqPKedXXMHKwFPev4M58

# then you can start to install with command below

./subspace-auto-install.sh
```


### Manual
###### Create folder and copy 2 file docker-compose.yaml + .env inside each folder
```
cd $HOME
mkdir node1
cd node1
wget -O docker-compose.yaml https://raw.githubusercontent.com/owlstake/testnet/main/subspace/docker-compose.yaml
wget -O .env https://raw.githubusercontent.com/owlstake/testnet/main/subspace/.env
```
### you can check which port you are using by this command
```
lsof -i -P -n | grep LISTEN
```
#### After finished download, you need to change variable inside file .env
#### each file .env should be another ports, another node name, another reward address
```
nano .env
```
###### Some command
###### start a node
```
docker compose up -d
```
###### show all docker running
```
docker ps
```
###### show logs
```
docker compose logs -f --tail=100 | grep <container-name>
```
###### stop a node
```
docker compose down
```

### If you want run the second node or n node, just change the code here, node2 --> noden
```
cd $HOME
mkdir node2
cd node2
wget -O docker-compose.yaml https://raw.githubusercontent.com/owlstake/testnet/main/subspace/docker-compose.yaml
wget -O .env https://raw.githubusercontent.com/owlstake/testnet/main/subspace/.env

Change ports, nodename, reward address inside .env file
nano .env

docker compose up -d
```
