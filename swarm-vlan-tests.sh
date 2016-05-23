#!/bin/bash
#
###########################################
###  Swarm Global Macvlan Driver Tests ###
###  ./global-vlan-test.sh <Swarm_IP>  ###
##########################################
#
if [[ "$1" == "" ]]; then
    echo "----> Defaulting to a Swarm local host and port 0.0.0.0:2376"
    SW_HOST="0.0.0.0"
fi

if [[ "$1" != "" ]]; then
    SW_HOST=${1}
    echo "----> Using specified Swarm target ${1}:2376"
fi

### parent-file eth0.30 802.1q
echo eth0.30 > /home/brent/macvlan-eth0.30.conf
docker -H tcp://${SW_HOST}:2376 network create -d macvlan --subnet=172.16.86.0/24 --gateway=172.16.86.2 -o parent-file=/home/brent/macvlan-eth0.30.conf mcv30
sleep 1
docker run --net=mcv30 -itd alpine /bin/sh
docker rm -f `docker ps -ql`
docker -H tcp://${SW_HOST}:2376 network rm mcv30
##########################################################
### parent list eth0.10 802.1q
docker -H tcp://${SW_HOST}:2376 network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=bond0,eth1,eth1,eth0 mcv10
sleep 1
docker run --net=mcv10 -itd alpine /bin/sh
docker rm -f `docker ps -ql`
docker -H tcp://${SW_HOST}:2376 network rm mcv10
##########################################################
### parent list eth0.20 802.1q
docker -H tcp://${SW_HOST}:2376 network create -d macvlan --subnet=192.168.20.0/24 --gateway=192.168.20.1 -o parent="bond0, eth0,  eth1" mcv20
sleep 1
docker run --net=mcv20 -itd alpine /bin/sh
docker rm -f `docker ps -ql`
docker -H tcp://${SW_HOST}:2376 network rm mcv20
##########################################################
### parent-file eth0
echo eth0 > /home/brent/macvlan-eth0.conf
docker -H tcp://${SW_HOST}:2376 network create -d macvlan --subnet=172.16.86.0/24 --gateway=172.16.86.2 -o parent-file=/home/brent/macvlan-eth0.conf  mcv0
sleep 1
docker run --net=mcv0 -itd alpine /bin/sh
docker rm -f `docker ps -ql`
docker -H tcp://${SW_HOST}:2376 network rm mcv0
##########################################################
### parent list eth0
docker -H tcp://${SW_HOST}:2376 network create -d macvlan --subnet=172.16.86.0/24 --gateway=172.16.86.2 -o parent="bond0, eth0,  eth1" mcv0
sleep 1
docker run --net=mcv0 -itd alpine /bin/sh
docker rm -f `docker ps -ql`
docker -H tcp://${SW_HOST}:2376 network rm mcv0
##########################################################
### --internal option
docker -H tcp://${SW_HOST}:2376 network create -d macvlan --internal mcv0
sleep 1
docker run --net=mcv0 -itd alpine /bin/sh

docker rm -f `docker ps -ql`
docker -H tcp://${SW_HOST}:2376 network rm mcv0
