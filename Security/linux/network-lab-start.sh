#!/bin/bash

# Create namespaces
sudo ip netns add centos
sudo ip netns add asav
sudo ip netns add vsrx

# Create veth pair for centos-to-centos communication
sudo ip link add v-eth1 type veth peer name v-peer1

# Add interfaces to namespaces
sudo ip link set v-peer1 netns centos
sudo ip link set ens256 netns asav
sudo ip link set ens224 netns vsrx

# Assign IP addresses
sudo ip addr add 11.0.0.1/24 dev v-eth1
sudo ip addr add 11.0.0.2/24 dev v-eth1
sudo ip netns exec centos ip a a 11.0.0.11/24 dev v-peer1
sudo ip netns exec asav ip a a 11.0.0.11/24 dev ens256
sudo ip netns exec vsrx ip a a 11.0.0.11/24 dev ens224

# Set interfaces UP
sudo ip link set v-eth1 up
sudo ip netns exec centos ip link set v-peer1 up
sudo ip netns exec asav ip link set ens256 up
sudo ip netns exec vsrx ip link set ens224 up

# Add ipset rules
sudo ipset create SYSLOG-SERVER hash:ip hashsize 4096 comment
sudo ipset add SYSLOG-SERVER 10.254.0.1 comment "host-syslog01-10.254.0.1"
sudo ipset add SYSLOG-SERVER 10.254.0.2 comment "host-syslog01-10.254.0.2"
sudo ipset add SYSLOG-SERVER 10.254.0.3 comment "host-syslog01-10.254.0.3"
sudo ipset add SYSLOG-SERVER 10.254.0.4 comment "host-syslog01-10.254.0.4"
sudo ipset add SYSLOG-SERVER 10.254.0.5 comment "host-syslog01-10.254.0.5"
sudo ipset add SYSLOG-SERVER 10.254.0.6 comment "host-syslog01-10.254.0.6"
sudo ipset add SYSLOG-SERVER 10.254.0.7 comment "host-syslog01-10.254.0.7"
sudo ipset add SYSLOG-SERVER 10.254.0.8 comment "host-syslog01-10.254.0.8"
sudo ipset add SYSLOG-SERVER 10.254.0.9 comment "host-syslog01-10.254.0.9"

sudo ipset create SNMP-SERVER hash:ip hashsize 4096 comment
sudo ipset add SNMP-SERVER 10.253.0.1 comment "host-snmp01-10.253.0.1"
sudo ipset add SNMP-SERVER 10.253.0.2 comment "host-snmp01-10.253.0.2"
sudo ipset add SNMP-SERVER 10.253.0.3 comment "host-snmp01-10.253.0.3"
sudo ipset add SNMP-SERVER 10.253.0.4 comment "host-snmp01-10.253.0.4"
sudo ipset add SNMP-SERVER 10.253.0.5 comment "host-snmp01-10.253.0.5"
sudo ipset add SNMP-SERVER 10.253.0.6 comment "host-snmp01-10.253.0.6"
sudo ipset add SNMP-SERVER 10.253.0.7 comment "host-snmp01-10.253.0.7"
sudo ipset add SNMP-SERVER 10.253.0.8 comment "host-snmp01-10.253.0.8"
sudo ipset add SNMP-SERVER 10.253.0.9 comment "host-snmp01-10.253.0.9"

sudo ipset create BLOCK-LIST hash:ip hashsize 4096 comment
sudo ipset add BLOCK-LIST 11.0.0.101 comment "host-11.0.0.101"
sudo ipset add BLOCK-LIST 11.0.0.102 comment "host-11.0.0.102"
sudo ipset add BLOCK-LIST 11.0.0.103 comment "host-11.0.0.103"
sudo ipset add BLOCK-LIST 11.0.0.103 comment "host-11.0.0.104"
sudo ipset add BLOCK-LIST 11.0.0.104 comment "host-11.0.0.104"
sudo ipset add BLOCK-LIST 11.0.0.105 comment "host-11.0.0.105"
sudo ipset add BLOCK-LIST 11.0.0.105 comment "host-11.0.0.106"
sudo ipset add BLOCK-LIST 11.0.0.106 comment "host-11.0.0.106"
sudo ipset add BLOCK-LIST 11.0.0.107 comment "host-11.0.0.107"
sudo ipset add BLOCK-LIST 11.0.0.107 comment "host-11.0.0.108"
sudo ipset add BLOCK-LIST 11.0.0.108 comment "host-11.0.0.108"
sudo ipset add BLOCK-LIST 11.0.0.109 comment "host-11.0.0.109"

# Add iptables rules
sudo iptables -I INPUT -i v-eth1 -m set --match-set BLOCK-LIST src -j DROP
sudo iptables -I FORWARD -i v-eth1 -m set --match-set BLOCK-LIST src -j DROP

# Add static arp (there are several arp-proxys in this subnet)
sudo ip netns exec vsrx arp -s 11.0.0.2 00:50:56:b2:1f:2e
