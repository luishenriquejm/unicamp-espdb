#!/bin/bash

v_PG_VERSION=$1
# v_PG_VERSION=18

dnf install -y tree

# repo 12
cat << EOF > /etc/yum.repos.d/pgdg-12.repo
[pgdg12-archive]
name=PostgreSQL 12 RPMs for RHEL/Rocky Linux/AlmaLinux 9.0
baseurl=https://yum-archive.postgresql.org/12/redhat/rhel-9-x86_64
enabled=1
gpgcheck=1
gpgkey=https://yum.postgresql.org/keys/PGDG-RPM-GPG-KEY-RHEL
EOF

# repo 13
cat << EOF > /etc/yum.repos.d/pgdg-13.repo
[pgdg13-archive]
name=PostgreSQL 13 RPMs for RHEL/Rocky Linux/AlmaLinux 9.0
baseurl=https://yum-archive.postgresql.org/13/redhat/rhel-9-x86_64
enabled=1
gpgcheck=1
gpgkey=https://yum.postgresql.org/keys/PGDG-RPM-GPG-KEY-RHEL
EOF

# repo 14, 15, 16, 17, 18
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm

dnf install -y postgresql${v_PG_VERSION}-server postgresql${v_PG_VERSION}-contrib
mkdir -p /postgres/${v_PG_VERSION}/data/
chown -R postgres:postgres /postgres
mkdir /etc/systemd/system/postgresql-${v_PG_VERSION}.service.d/
cat << EOF > /etc/systemd/system/postgresql-${v_PG_VERSION}.service.d/override.conf
[Service]
Environment=PGDATA=/postgres/${v_PG_VERSION}/data/
EOF

/usr/pgsql-${v_PG_VERSION}/bin/postgresql-${v_PG_VERSION}-setup initdb

# adjustments
sed -i "s/#password_encryption = md5/password_encryption = scram-sha-256/g" /postgres/${v_PG_VERSION}/data/postgresql.conf
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /postgres/${v_PG_VERSION}/data/postgresql.conf
sed -i "s/#port = 5432/port = 5432/g" /postgres/${v_PG_VERSION}/data/postgresql.conf

systemctl enable postgresql-${v_PG_VERSION}
systemctl start postgresql-${v_PG_VERSION}

echo "export PATH=/usr/pgsql-${v_PG_VERSION}/bin:$PATH" >> /var/lib/pgsql/.bash_profile
echo "export PGPORT=5432" >> /var/lib/pgsql/.bash_profile

# set pg_hba.conf
echo "host    all             all             10.0.1.0/24             scram-sha-256" >> /postgres/${v_PG_VERSION}/data/pg_hba.conf

systemctl reload postgresql-${v_PG_VERSION}
systemctl restart postgresql-${v_PG_VERSION}

# allow port on firewall
# dnf install -y firewalld
# systemctl enable --now firewalld
firewall-cmd --permanent --add-port=5432/tcp
firewall-cmd --reload

# check
rpm -qa | grep -i postgresql | grep -i server | sort -n
tree /postgres
ls -lc /etc/systemd/system/postgresql-*.service.d/ß.conf
cat /etc/systemd/system/postgresql-*.service.d/override.conf
tree -d -L 3 /postgres
systemctl list-unit-files --type=service | grep -i postgres
firewall-cmd --list-ports
