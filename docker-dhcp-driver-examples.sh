#!/bin/sh
#
# Driver details (in devel) https://gist.github.com/nerdalert/3d2b891d41e0fa8d688c
#
docker network create -d macvlan --ipam-driver=dhcp --subnet=172.16.86.0/24 --gateway=172.16.86.2 -o parent=eth0.10 --ipam-opt dhcp_interface=eth1.10 mcv0

docker network rm mcv0

#######################################################################################################

docker network create -d macvlan --ipam-driver=dhcp --subnet=172.16.86.0/24 -o parent=eth0.10 --ipam-opt dhcp_interface=eth1.10 mcv0

docker rm -f `docker ps -qa`
docker network rm mcv0

#######################################################################################################

docker network create -d macvlan --ipam-driver=dhcp -o parent=eth0 --ipam-opt dhcp_interface=eth0 mcv0

docker run --net=mcv0 -itd alpine /bin/sh
docker run --net=mcv0 -itd alpine /bin/sh

docker rm -f `docker ps -qa`
docker network rm mcv0

#######################################################################################################

docker network create -d macvlan --ipam-driver=dhcp --subnet=172.16.86.0/24  --gateway=172.16.86.2  -o parent=eth0 --ipam-opt dhcp_interface=eth0 mcv0

docker run --net=mcv0 -itd alpine /bin/sh
docker run --net=mcv0 -itd alpine /bin/sh

docker rm -f `docker ps -qa`
docker network rm mcv0

#######################################################################################################

docker network create -d macvlan --ipam-driver=dhcp --subnet=172.16.86.0/24  -o parent=eth0 --ipam-opt dhcp_interface=eth1 mcv0

docker run --net=mcv0 -itd alpine /bin/sh
docker run --net=mcv0 -itd alpine /bin/sh

#######################################################################################################

docker network create -d macvlan --ipam-driver=dhcp -o parent=eth1 --subnet=192.168.1.0/24  --ipam-opt dhcp_interface=eth1 mcv1

docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh

docker rm -f `docker ps -qa`
docker network rm mcv1

#######################################################################################################

docker network create -d macvlan --ipam-driver=dhcp -o parent=eth1 --subnet=192.168.1.0/24 --gateway=192.168.1.1  --ipam-opt dhcp_interface=eth1 mcv1

docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh

docker rm -f `docker ps -qa`
docker network rm mcv1

#######################################################################################################

docker network create -d macvlan --ipam-driver=dhcp -o parent=eth1 --ipam-opt dhcp_interface=eth1 mcv1

docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh

docker rm -f `docker ps -qa`
docker network rm mcv1

#######################################################################################################

docker network create -d macvlan --ipam-driver=dhcp -o parent=eth1 --ipam-opt dhcp_interface=eth1 mcv1

docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh
docker run --net=mcv1 -itd alpine /bin/sh

docker rm -f `docker ps -qa`
docker network rm mcv1
