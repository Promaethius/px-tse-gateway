terraform {
    required_providers {
        vsphere = {
            source = "hashicorp/vsphere"
            version = "1.26.0"
        }
        ct = {
            source  = "poseidon/ct"
            version = "0.8.0"
        }
    }
}

provider "vsphere" {
    user           = var.vsphere.user
    password       = var.vsphere.password
    vsphere_server = var.vsphere.server

    allow_unverified_ssl = true
}

locals {
    ssh-rsa = var.gateway.ssh-rsa != "" ? var.gateway.ssh-rsa : (fileexists("~/.ssh/id_rsa.pub") ? file("~/.ssh/id_rsa.pub") : "")
    name    = "${var.gateway.hostname}-${random_string.hash.result}"
}

resource "random_string" "hash" {
  length  = 6
  special = false
  upper   = false
}

data "vsphere_datacenter" "datacenter" {
    name = var.vsphere.datacenter
}

data "vsphere_datastore" "datastore" {
    name          = var.vsphere.datastore
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "public_network" {
    name          = "VM Network"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
    name          = var.vsphere.host
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_host_port_group" "subnet" {
    name                = local.name
    host_system_id      = data.vsphere_host.host.id
    virtual_switch_name = "vSwitch0"
}

resource "time_sleep" "wait_on_net" {
    depends_on    = [vsphere_host_port_group.subnet]
    create_duration = "10s"
}

data "vsphere_network" "private_network" {
    depends_on    = [time_sleep.wait_on_net]
    name          = local.name
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
    name          = "/${var.vsphere.datacenter}/host/${var.vsphere.folderpath}/${var.vsphere.host}/Resources"
    datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "template_file" "gateway" {
    template = "${file("${path.module}/gateway.yaml")}"
    vars     = {
        ssh-rsa  = local.ssh-rsa
        hostname = local.name

        public-static  = var.gateway.public-static
        public-gateway = var.gateway.public-gateway

        subnet-gateway = var.gateway.subnet.gateway
        subnet-min     = var.gateway.subnet.min
        subnet-max     = var.gateway.subnet.max
        intra-dns      = join(" ", var.gateway.subnet.intra_dns)

        px-versions     = join(" ", var.gateway.loader.px-versions)
        k8s-versions    = join(" ", var.gateway.loader.k8s-versions)
        calico-versions = join(" ", var.gateway.loader.calico-versions)
        csi-versions    = join(" ", var.gateway.loader.csi-versions)
        extras          = join(" ", var.gateway.loader.extras)
    }
}

data "ct_config" "ignition" {
    content      = data.template_file.gateway.rendered
    strict       = true
    pretty_print = false

    snippets = [
        file("${path.module}/scripts.yaml")
    ]
}

resource "vsphere_virtual_machine" "gateway" {
    name             = local.name
    host_system_id   = data.vsphere_host.host.id
    datacenter_id    = data.vsphere_datacenter.datacenter.id
    datastore_id     = data.vsphere_datastore.datastore.id
    resource_pool_id = data.vsphere_resource_pool.pool.id

    num_cpus = 4
    memory   = 4096
    guest_id = "other3xLinux64Guest"

    network_interface {
        network_id = data.vsphere_network.public_network.id
    }

    network_interface {
        network_id = data.vsphere_network.private_network.id
    }

    disk {
        label = "disk0"
        size  = 75
    }

    dynamic "ovf_deploy" {
        for_each = fileexists("./flatcar_production_vmware_ova.ova") ? [] : [1]
        content {
            remote_ovf_url    = "https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_vmware_ova.ova"
            disk_provisioning = "thin"
        }
    }

    dynamic "ovf_deploy" {
        for_each = fileexists("./flatcar_production_vmware_ova.ova") ? [1] : []
        content {
            local_ovf_path    = "./flatcar_production_vmware_ova.ova"
            disk_provisioning = "thin"
        }
    }

    vapp {
        properties = {
            "guestinfo.hostname"                      = local.name
            "guestinfo.ignition.config.data"          = base64encode(data.ct_config.ignition.rendered)
            "guestinfo.ignition.config.data.encoding" = "base64"
        }
    }
}