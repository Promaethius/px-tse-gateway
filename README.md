# TSE Portworx Lab Gateway
## Introduction
This terraform module solves one very specific issue: DHCP for Portworx TSEs in vSphere "Lab" Environments. Additionally, through caching of various objects, the total time to spin up and tear down Kubernetes/Portworx clusters within vSphere is reduced significantly. This is achieved through a stateless vSphere Virtual Machine based upon Kinvolk's Flatcar Linux.

## Requirements
* Authentication to https://10.14.84.210/
* VPN Connection through the Pure Bellvue, WA Gateway.
* An available static IP in an acceptible range for the VM.
* Knowedge of internal Gateway IP.
* Knowledge of internal DNS Nameservers.

## Quick Start
NOTE: This pulls down the production flatcar image and passes it through a pipe to vSphere. To speed this process up, pull the image down locally into the module folder. Additionally, this will read for ~/.ssh/id_rsa.pub to autopopulate gateway.id-rsa if left blank.
The default subnet will be 192.167.0.2-249 with 192.167.0.1 as the gateway/dns/registry/pkg address and 192.167.0.250-254 as management addresses for static services.
Versions of Portworx, Kubernetes, Calico, vSphere CSI, and extras are visible in vars.tf
```
module "gateway" {
    source = "github.com/Promaethius/px-tse-gateway"

    vsphere = {
        user       = "" #Required
        password   = "" #Required
        server     = "" #Required
        host       = "" #Required i.e. "10.15.84.20"
        datacenter = "" #Required i.e. "Portworx-TSE"
        datastore  = "" #Required i.e. "Jonathan-DS"
        folderpath = "" #Optional i.e. "/jbryant/"
    }
}
```
Once provisioned, you should be able to ssh into the gateway with the static address you specified.