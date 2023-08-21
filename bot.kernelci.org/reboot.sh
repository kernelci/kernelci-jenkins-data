#!/bin/sh

set -e

echo "Cleaning big clusters"

for ctx in \
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

# Jenkins workspace cleanup
WORKSPACE_PATH="/data/workspace/bot.kernelci.org/"
host="kernelci-prod-jenkins-runner-3.westus3.cloudapp.azure.com"
workspace="build-trigger"
echo "[$host] Deleting $WORKSPACE_PATH/$workspace/workspace/*"
ssh $host sudo "sh -c 'rm -rf $WORKSPACE_PATH/$workspace/workspace/*'"

for host in \
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
