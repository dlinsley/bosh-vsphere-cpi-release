#!/usr/bin/env bash

# A regular expression matching the names of potential datastores the director
# will use for storing VMs and associated persistent disks. Note that the name
# of each datastore matched by this regular expression must correspond to a
# unique managed object across the entire vCenter (it is not sufficient for the
# datastore name to be unique across a single datacenter). Otherwise this error
# occurs during the create-env:
#   Found more than one VimSdk::Vim::Datastore: name: "isc-cl1-ds-0"
# For example in vcpi-nimbus the nfs-server serving the nfs0-1 datastore is
# attached to all hosts including those in the nested datacenter
# vcpi-dc-nested. Because managed objects are scoped to a single datacenter the
# managed object representing the nfs0-1 datastore inside *vcpi-dc* is distinct
# from the managed object representing the nfs0-1 datastore inside
# *vcpi-dc-nested*. In this case a regular expression matching nfs0-1 will
# resolve to both managed objects thus causing the aforementioned error.
unambiguous_ds=isc-cl1-ds-1

source environment/metadata

bosh int \
  -o bosh-deployment/vsphere/cpi.yml \
  -o bosh-deployment/misc/powerdns.yml \
  -o bosh-deployment/misc/proxy.yml \
  -o bosh-deployment/jumpbox-user.yml \
  -o bosh-deployment/vsphere/resource-pool.yml \
  -o certification/shared/assets/ops/custom-releases.yml \
  -o certification/vsphere/assets/ops/custom-cpi-release.yml \
  -o certification/shared/assets/ops/redis.yml \
  -o certification/shared/assets/ops/remove-hm.yml \
  -o certification/shared/assets/ops/remove-provider-cert.yml \
  -v bosh_release_uri="file://$(echo bosh-release/*.tgz)" \
  -v cpi_release_uri="file://$(echo cpi-release/*.tgz)" \
  -v stemcell_uri="file://$(echo stemcell/*.tgz)" \
  -v director_name=bosh \
  -v internal_cidr=192.168.111.0/24 \
  -v internal_gw=192.168.111.1 \
  -v internal_ip=192.168.111.106 \
  -v network_name="$BOSH_VSPHERE_VLAN" \
  -v vcenter_dc="$BOSH_VSPHERE_CPI_DATACENTER" \
  -v vcenter_ds="$unambiguous_ds" \
  -v vcenter_ip="$BOSH_VSPHERE_CPI_HOST" \
  -v vcenter_user="$BOSH_VSPHERE_CPI_USER" \
  -v vcenter_password="$BOSH_VSPHERE_CPI_PASSWORD" \
  -v vcenter_templates=bosh-stemcell \
  -v vcenter_vms=bosh-vm \
  -v vcenter_disks=bosh-disk \
  -v vcenter_cluster="$BOSH_VSPHERE_CPI_CLUSTER" \
  -v vcenter_rp="$BOSH_VSPHERE_CPI_RESOURCE_POOL" \
  -v dns_recursor_ip="8.8.8.8" \
  -v http_proxy="http://$BOSH_VSPHERE_JUMPER_HOST:80" \
  -v https_proxy="http://$BOSH_VSPHERE_JUMPER_HOST:80" \
  -v no_proxy="localhost,127.0.0.1" \
  bosh-deployment/bosh.yml > director-config/director.yml