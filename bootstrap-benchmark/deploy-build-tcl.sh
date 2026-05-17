#!/bin/bash

source /tmp/.p

cat << EOF > /opt/unicamp-espdb/run-hammerdb/build.tcl
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

diset tpcc pg_count_ware 1000
diset tpcc pg_num_vu 8

buildschema
waittocomplete
vudestroy
quit
EOF
