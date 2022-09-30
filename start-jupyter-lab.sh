#!/bin/sh
# run this file from inside the container to start jupyter lab in the container,
# and use it on port localhost:8888 on the host system.
jupyter lab --LabApp.token='' --ip=${HOSTNAME} 
