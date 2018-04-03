#!/bin/bash
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
#terraform plan -var="cluster_up=${cluster_up}" -var="nodes_count=${nodes_count}"
ELB_DNS=$(terraform output elb_ip)
echo ${ELB_DNS}
kubectl config set-cluster $NAME --server="${ELB_DNS}" --insecure-skip-tls-verify

