#!/bin/sh

set -e

for host in \
    "kernelci1.eastus.cloudapp.azure.com" \
    "kernelci6.westus2.cloudapp.azure.com" \
    "kernelci-jenkins-europe.westeurope.cloudapp.azure.com" \
    "kernelci-jenkins-usa.westus2.cloudapp.azure.com" \
    ; do
    echo "[$host]"
    ssh $host sudo "sh -c 'docker system prune -f && shutdown -r now'" &
done

ssh kernelci.org 'cd kernelci-jenkins && docker-compose restart'

exit 0
