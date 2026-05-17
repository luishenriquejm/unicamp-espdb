#!/bin/bash

source /tmp/.p

cat << EOF > /opt/unicamp-espdb/run-hammerdb/run.tcl
dbset db pg
dbset bm TPC-C

diset connection pg_host 10.0.1.50
diset connection pg_port 5432
diset connection pg_sslmode disable

diset tpcc pg_superuser dba
diset tpcc pg_superuserpass ${v_PG_PASS}
diset tpcc pg_defaultdbase postgres
diset tpcc pg_user hammerdb
diset tpcc pg_pass hammerdb
diset tpcc pg_dbase tpcc

diset tpcc pg_driver timed
diset tpcc pg_rampup 5
diset tpcc pg_duration 30
diset tpcc pg_vacuum false

vuset logtotemp 1
vuset vu 16
vucreate
vurun
waittocomplete
vudestroy
quit
EOF
