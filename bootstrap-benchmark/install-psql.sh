#!/bin/bash

source /tmp/.p

v_PG_VERSION=$1
# v_PG_VERSION=18

dnf install -y tree

# repo 12
if [ $v_PG_VERSION -eq 12 ]; then
cat << EOF > /etc/yum.repos.d/pgdg-12.repo
[pgdg12-archive]
name=PostgreSQL 12 RPMs for RHEL/Rocky Linux/AlmaLinux 9.0
baseurl=https://yum-archive.postgresql.org/12/redhat/rhel-9-x86_64
enabled=1
gpgcheck=1
gpgkey=https://yum.postgresql.org/keys/PGDG-RPM-GPG-KEY-RHEL
EOF
fi

# repo 13
if [ $v_PG_VERSION -eq 13 ]; then
cat << EOF > /etc/yum.repos.d/pgdg-13.repo
[pgdg13-archive]
name=PostgreSQL 13 RPMs for RHEL/Rocky Linux/AlmaLinux 9.0
baseurl=https://yum-archive.postgresql.org/13/redhat/rhel-9-x86_64
enabled=1
gpgcheck=1
gpgkey=https://yum.postgresql.org/keys/PGDG-RPM-GPG-KEY-RHEL
EOF
fi

# repo 14, 15, 16, 17, 18j
if [ $v_PG_VERSION -ge 14 ]; then
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
fi

dnf install -y postgresql${v_PG_VERSION}
