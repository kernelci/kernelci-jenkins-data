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

ssh kernelci.org '\
cd kernelci-jenkins && \
git remote update && \
git checkout origin/kernelci.org && \
cd data && \
git pull --ff-only && \
cd - && \
docker-compose restart'

exit 0
