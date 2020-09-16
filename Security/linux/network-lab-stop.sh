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
