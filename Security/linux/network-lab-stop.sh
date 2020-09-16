# Move interfaces to default NS
sudo ip netns exec asav ip link set ens256 netns 1
sudo ip netns exec vsrx ip link set ens224 netns 1
sudo ip netns exec centos ip link set v-peer1 netns 1

# Remove NS
sudo ip netns delete centos
sudo ip netns delete asav
sudo ip netns delete vsrx

# Remove veth pair
sudo ip link delete v-eth1

# Remove iptables rules
sudo iptables -D INPUT -i v-eth1 -m set --match-set BLOCK-LIST src -j DROP
sudo iptables -D FORWARD -i v-eth1 -m set --match-set BLOCK-LIST src -j DROP

# Remove ipset
sudo ipset x BLOCK-LIST
sudo ipset x SNMP-SERVER
sudo ipset x SYSLOG-SERVER

# Remove static arp
sudo ip netns exec vsrx arp -d 11.0.0.2
