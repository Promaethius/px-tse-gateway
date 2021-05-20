# TSE Portworx Lab Gateway

## Introduction
This terraform module solves one very specific issue: DHCP for Portworx TSEs in vSphere "Lab" Environments. Additionally, through caching of various objects, the total time to spin up and tear down Kubernetes/Portworx clusters within vSphere is reduced significantly. This is achieved through a stateless vSphere Virtual Machine based upon Kinvolk's Flatcar Linux.

## Services Exposed
1. Docker registry with self-signed certificates.
2. Portworx NFS package repos exposed on :8080
3. DNS Cache through DHCP settings.
4. ETCD Server for Portworx deployments (unsecured).


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

    gateway_public_ip      = "" #Required. Must be a free static IP.
    gateway_public_gateway = "" #Required
}
```
Once provisioned, you should be able to ssh into the gateway with the static address you specified.

Machines are provisioned into the subnet by attaching the created host port group to vNIC on guest VMs.

## Tips and Tricks

### Speeding up Deployment
Run `curl -L https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_vmware_ova.ova -O` into the current terraform folder. This will speed up the deployment process as the module scans for the image locally before attempting to stream it to vSphere.
Rather than copy pasting your SSH pub key, leave it blank and the module will fetch your public key for you from ~/.ssh/id_rsa.pub

### Wiping ETCD
Simply run `sudo systemctl restart etcd` and your portworx keys will be wiped.

### Adding Images After Deployment
1. `sudo vi /etc/systemd/system/registry.service`
2. Add your extra images to the EXTRAS environment variable.
3. `sudo rm /var/lib/registry/images.lock`
4. `sudo systemctl restart registry` will restart the registry and begin reloading images.

### Trusting Registry CA
Note: `export $GATEWAY_IP=<gateway_ip>`
These commands can be run through machines on the subnet and will import the registry CA into trusted stores.

Debian/Ubuntu:
```
openssl s_client -showcerts -connect $GATEWAY_IP:443 </dev/null 2>/dev/null | awk '
  inside {
    text = text $0 RS
    if (/-----END CERTIFICATE-----/) inside=0
    next
  }
  /-----BEGIN CERTIFICATE-----/ {
    inside = 1
    text = $0 RS
  }
  END {printf "%s", text}' > /usr/local/share/ca-certificates/registry.crt
update-ca-certificates
```

CentOS/Fedora:
```
openssl s_client -showcerts -connect $GATEWAY_IP:443 </dev/null 2>/dev/null | awk '
  inside {
    text = text $0 RS
    if (/-----END CERTIFICATE-----/) inside=0
    next
  }
  /-----BEGIN CERTIFICATE-----/ {
    inside = 1
    text = $0 RS
  }
  END {printf "%s", text}' > /usr/share/pki/ca-trust-source/anchors/registry.pem
update-ca-trust
```