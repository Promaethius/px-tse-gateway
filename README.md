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

    gateway = {
        id-rsa         = "" #Optional
        public-static  = "" #Required i.e. "10.15.84.x"
        public-gateway = "" #Required Internal Gateway.
        subnet         = {
            intra_dns = [""] #Optional internal DNS Nameservers.
        }
    }

    gateway = {
        hostname       = "gateway"
        ssh-rsa        = ""
        public-static  = "10.15.84.x" #Required
        public-gateway = "10.15.84.1"
        subnet         = {
            gateway   = "192.167.0.1"
            min       = ""
            max       = ""
            intra_dns = ["10.14.250.53", "10.14.250.250"]
        }
        loader         = {
            px-versions     = ["2.6.0", "2.7.0"]
            k8s-versions    = ["1.18.2", "1.20.1"]
            calico-versions = ["3.15"]
            csi-versions    = ["2.2.0"]
            extras          = [
                "plndr/kube-vip:0.3.2",
                "quay.io/coreos/prometheus-operator:v0.34.0",
                "quay.io/coreos/prometheus-config-reloader:v0.34.0",
                "quay.io/coreos/configmap-reload:v0.0.1",
                "quay.io/prometheus/prometheus:v2.7.1"
            ]
        }
    }
}
```
Once provisioned, you should be able to ssh into the gateway with the static address you specified.