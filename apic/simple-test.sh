#!/bin/bash

cd /opt/stack/devstack
. openrc admin demo

if nova list | grep vm001 1>/dev/null
then
  echo "Test already ran"
  nova list
  exit 1
fi

set -e
TENANT=$(keystone tenant-list | awk '/demo/ {print $2}')
neutron net-create --tenant-id $TENANT net001
neutron subnet-create --tenant-id $TENANT --name subnet001 net001 10.10.1.0/24
neutron net-create --tenant-id $TENANT net002
neutron subnet-create --tenant-id $TENANT --name subnet002 net002 10.10.2.0/24
neutron net-list

neutron router-create --tenant-id $TENANT router001
neutron router-interface-add router001 subnet001
neutron router-interface-add router001 subnet002
neutron router-list
neutron router-port-list router001

NET1=$(neutron net-list | awk '/net001/ {print $2}')
NET2=$(neutron net-list | awk '/net002/ {print $2}')
IMAGE=$(nova image-list | awk '/cirros-0.3.1-x86_64-uec\ / {print $2}')
FLAVOR=m1.tiny

nova boot --image $IMAGE --flavor $FLAVOR --nic net-id=$NET1 vm001
sleep 10
nova boot --image $IMAGE --flavor $FLAVOR --nic net-id=$NET1 vm002
sleep 10
nova boot --image $IMAGE --flavor $FLAVOR --nic net-id=$NET2 vm003
sleep 10
nova list