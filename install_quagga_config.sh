################
# Installation #
################
# Painful Quagga install
# See https://github.com/osrg/gobgp/ gobgp for non-painful BGP daemon (its awesome)
### Install Quagga

 sudo apt-get install quagga quagga-doc
 sudo cp /usr/share/doc/quagga/examples/zebra.conf.sample /etc/quagga/zebra.conf
 sudo cp /usr/share/doc/quagga/examples/ospfd.conf.sample /etc/quagga/ospfd.conf
 sudo cp /usr/share/doc/quagga/examples/bgpd.conf.sample /etc/quagga/bgpd.conf

chown quagga.quaggavty /etc/quagga/*.conf
chmod 640 /etc/quagga/*.conf

### Enable the Quagga BGP Daemon
# Manually
# sudo vi /etc/quagga/daemons
# zebra=yes
# bgpd=yes
# ospfd=yes

# following adds the above (zebra is what modifies netlink in the underlying OS)
sed -i 's/zebra=no/zebra=yes/' /etc/quagga/daemons
sed -i 's/bgpd=no/bgpd=yes/' /etc/quagga/daemons
sed -i 's/ospfd=no/ospfd=yes/' /etc/quagga/daemons

### Setup Log Files
mkdir /var/log/quagga/
touch /var/log/quagga/zebra.log
touch /var/log/quagga/ospfd.log
touch /var/log/quagga/bgpd.log

sudo chown quagga.quaggavty /var/log/quagga/*.log

### Change Permissions and Enable IPv4 Forwarding
sudo chown quagga.quaggavty /etc/quagga/*.conf
sudo chmod 640 /etc/quagga/*.conf
sudo service quagga restart
sudo su -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo /etc/init.d/quagga restart

sudo netstat -nlptu | grep zebra

### Setup the CLI

sudo cp /usr/share/doc/quagga/examples/vtysh.conf.sample /etc/quagga/vtysh.conf


# Start the CLI
vtysh

echo 'VTYSH_PAGER=more' >> ~/.bashrc
source  ~/.bashrc





