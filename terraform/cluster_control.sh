#!/bin/bash
# Variables that define how many masters ELBs and nodes there will be
cluster_up=0
nodes_count=0
OPTS=`getopt -o ud --long up,down -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

echo "OPTS"$OPTS
eval set -- "$OPTS"

while true; do
	case "$1" in
		-u|--up) echo "Cluster going up"; cluster_up=1; nodes_count=2; shift;;
		-d|--down) echo "Cluster going down"; shift;;
		--) shift; break ;;
		*) echo "Internal error!"; exit 1;;
	esac
done
echo 'cluster_up='${cluster_up}
echo 'nodes_count='${nodes_count}
# Use apply to bring up or down the cluster
terraform apply -var="cluster_up=${cluster_up}" -var="nodes_count=${nodes_count}" -auto-approve
ELB_DNS=$(terraform output elb_ip)
echo ${ELB_DNS}
# Set kubectl to target API server on created ELB
kubectl config set-cluster $NAME --server="https://${ELB_DNS}" --insecure-skip-tls-verify

