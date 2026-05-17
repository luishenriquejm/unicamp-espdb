#!/bin/bash

v_ADDRESS=$1

ssh -i ${HOME}/local/tech/keys/aws/aws-key-eu-central-1.pem -o StrictHostKeyChecking=No -l ec2-user ${v_ADDRESS}

