#!/bin/bash

source /tmp/.p

PGPASSWORD="${v_PG_PASS}" psql -h 10.0.1.50 -p 5432 -U dba postgres -c "select now();"
