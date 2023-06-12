#!/bin/sh

set -e

echo "Cleaning big clusters"

for ctx in \
    "aks-kbuild-big-1" \
    "gke_android-kernelci-external_europe-west1-d_kci-eu-west1" \
    "gke_android-kernelci-external_europe-west4-c_kci-eu-west4" \
    ; do
    echo "[$ctx]"
    ssh kernelci-prod-jenkins-runner-3.westus3.cloudapp.azure.com \
        sudo su buildslave "/bin/sh -c '\
        kubectl --context $ctx \
        delete pod --field-selector=status.phase!=Running'"
done

echo "Cleaning medium clusters"

for ctx in \
    "aks-kbuild-medium-1" \
    "aks-kbuild-medium-2" \
    "aks-kbuild-medium-3" \
    "gke_android-kernelci-external_us-central1-c_kci-us-central1" \
    "gke_android-kernelci-external_us-east4-c_kci-big-us-east4" \
    "gke_android-kernelci-external_us-west1-a_kci-us-west1" \
    ; do
    echo "[$ctx]"
    ssh kernelci-prod-jenkins-runner-3.westus3.cloudapp.azure.com \
        sudo su buildslave "/bin/sh -c '\
        kubectl --context $ctx \
        delete pod --field-selector=status.phase!=Running'"
done

for host in \
    "kernelci-prod-jenkins-runner-1.westus3.cloudapp.azure.com" \
    "kernelci-prod-jenkins-runner-2.westus3.cloudapp.azure.com" \
    "kernelci-prod-jenkins-runner-3.westus3.cloudapp.azure.com" \
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
