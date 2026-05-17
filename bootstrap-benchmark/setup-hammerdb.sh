#!/bin/bash

dnf install -y wget

wget https://github.com/TPC-Council/HammerDB/releases/download/v5.0/hammerdb-5.0-1.el9.x86_64.rpm

dnf localinstall -y hammerdb-5.0-1.el9.x86_64.rpm
