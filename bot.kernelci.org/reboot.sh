#!/bin/sh

set -e

for ctx in \
    "aks-kci-uk-south" \
    "gke_android-kernelci-external_europe-west1-d_kci-eu-west1" \
    "gke_android-kernelci-external_europe-west4-c_kci-eu-west4" \
    ; do
    echo "[$ctx]"
    ssh kernelci-jenkins-usa.westus2.cloudapp.azure.com \
        sudo su buildslave "/bin/sh -c '\
        kubectl --context $ctx \
        delete pod --field-selector=status.phase!=Running'"
done

for ctx in \
    "aks-kci-us-east2" \
    "gke_android-kernelci-external_us-central1-c_kci-us-central1" \
    "gke_android-kernelci-external_us-east4-c_kci-big-us-east4" \
    "gke_android-kernelci-external_us-west1-a_kci-us-west1" \
    ; do
    echo "[$ctx]"
    ssh kernelci-jenkins-usa.westus2.cloudapp.azure.com \
        sudo su buildslave "/bin/sh -c '\
        kubectl --context $ctx \
        delete pod --field-selector=status.phase!=Running'"
done

for host in \
    "kernelci1.eastus.cloudapp.azure.com" \
    "kernelci6.westus2.cloudapp.azure.com" \
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
