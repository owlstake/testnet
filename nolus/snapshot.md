#### Nolus Snapshot 

##### height: 1244911

##### size: 2.19G;

##### pruning: custom/100/0/10;

##### indexer: null

```
# install dependencies, if needed
sudo apt update
sudo apt install lz4 -y
# Stop nolusd service
sudo systemctl stop nolusd
# backup validator state
cp $HOME/.nolus/data/priv_validator_state.json $HOME/.nolus/priv_validator_state.json.backup
# Reset data folder
nolusd tendermint unsafe-reset-all --home $HOME/.nolus --keep-addr-book
# Download and extract the snapshot
curl https://snapshots.owlstake.com/nolus/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.nolus
# restore validator state
mv $HOME/.nolus/priv_validator_state.json.backup $HOME/.nolus/data/priv_validator_state.json
# Start nolusd service
sudo systemctl start nolusd
# Show the nolusd log
sudo journalctl -u nolusd -f --no-hostname -o cat
```
