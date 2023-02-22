### Update namada
```
NEWTAG=v0.14.1
cd $HOME
wget https://github.com/anoma/namada/releases/download/v0.14.1/namada-$NEWTAG-Linux-x86_64.tar.gz
tar -xzvf namada-$NEWTAG-Linux-x86_64.tar.gz
cd namada-$NEWTAG-Linux-x86_64.tar.gz
rm /usr/local/bin/namada /usr/local/bin/namadac /usr/local/bin/namadan /usr/local/bin/namadaw
cp namada* /usr/local/bin/
namada --version
```

### for POST genesis validator
```
systemctl stop namadad
export CHAIN_ID="public-testnet-4.0.16a35d789f4"
export ALIAS=owlstake

echo $CHAIN_ID
echo $ALIAS

rm -rf $HOME/.namada/public-testnet-*
rm $HOME/.namada/global-config.toml

namada client utils join-network \
--chain-id $CHAIN_ID --genesis-validator $ALIAS

systemctl start namadad
journalctl -u namadad -f -o cat 
```


### Make service
```
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.namada
Environment=NAMADA_LOG=debug
Environment=NAMADA_TM_STDOUT=true
ExecStart=/usr/local/bin/namada --base-dir=$HOME/.namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable namadad
sudo systemctl start namadad
```
