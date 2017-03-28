#!/bin/bash

apt-get update 
apt-get upgrade -y
apt-get install devscripts build-essential openssl libssl-dev fakeroot libcppunit-dev libsasl2-dev cdbs ccze libfile-readbackwards-perl libcap2 libcap-dev libcap2-dev libtool sysv-rc-conf -y

wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.24.tar.bz2
tar -xjf squid-3.5.24.tar.bz2
cd squid-3.5.24

./configure --prefix=/usr --includedir=/usr/include --infodir=/usr/share/info --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/lib/squid --srcdir=. --datadir=/usr/share/squid --sysconfdir=/etc/squid --mandir=/usr/share/man --enable-inline --enable-async-io=24 --enable-storeio=ufs,aufs,diskd,rock --enable-removal-policies=lru,heap --enable-gnuregex --enable-delay-pools --enable-cache-digests --enable-underscores --enable-icap-client --enable-follow-x-forwarded-for --enable-eui --enable-esi --enable-icmp --enable-zph-qos --enable-http-violations --enable-ssl-crtd --enable-linux-netfilter --enable-ltdl-install --enable-ltdl-convenience --enable-x-accelerator-vary --disable-maintainer-mode --disable-dependency-tracking --disable-silent-rules --disable-translation --disable-ipv6 --disable-ident-lookups --with-swapdir=/var/spool/squid --with-logdir=/var/log/squid --with-pidfile=/var/run/squid.pid --with-aufs-threads=24 --with-filedescriptors=65536 --with-large-files --with-maxfd=65536 --with-openssl  --with-default-user=proxy --with-included-ltdl

make && make install

cp squid.conf /etc/squid/
cp storeid.pl /etc/squid/
cp rc.local /etc/rc.local

mkdir /var/lib/squid
chown -R nobody /var/lib/squid/

/usr/lib/squid/ssl_crtd -c -s /var/lib/squid/ssl_db

chown -R proxy:proxy /var/lib/squid/ssl_db/
chmod -R 777 /var/lib/squid/ssl_db/
 
mkdir /etc/squid/ssl_cert
cd /etc/squid/ssl_cert

chmod +x /etc/squid/storeid.pl
chmod +x /etc/squid

chown proxy:proxy /cc-{1,2,3}
chmod 777 /cc-{1,2,3}

squid -f /etc/squid/squid.conf -z

wget --no-check-certificate -O /etc/init.d/squid https://gist.githubusercontent.com/e7d/1f784339df82c57a43bf/raw/squid.sh
chmod +x /etc/init.d/squid
update-rc.d squid defaults

 
