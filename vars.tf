variable "vsphere" {
    type = object({
        user       = string
        password   = string
        server     = string
        host       = string
        datastore  = string
        datacenter = string
        folderpath = string
    })
    default = {
        user       = ""
        password   = ""
        server     = ""
        host       = ""
        datacenter = ""
        datastore  = ""
        folderpath = ""
    }
}

variable "gateway" {
    type = object({
        hostname       = string
        ssh-rsa        = string
        public-static  = string
        public-gateway = string
        subnet         = object({
            gateway   = string
            min       = string
            max       = string
            intra_dns = list(string)
        })
        loader         = object({
            px-versions     = list(string)
            k8s-versions    = list(string)
            calico-versions = list(string)
            csi-versions    = list(string)
            extras          = list(string)
        })
    })
    default = {
        hostname       = "gateway"
        ssh-rsa        = ""
        public-static  = "10.15.84.25"
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
    validation{
        condition = can(
            (try(cidrhost("${var.gateway.public-static}/0", 0)) != "" ? true : false) &&
            (try(cidrhost("${var.gateway.public-gateway}/0", 0)) != "" ? true : false) &&
            (try(cidrhost("${var.gateway.subnet.gateway}/0", 0)) != "" ? true : false) &&
            (var.gateway.subnet.min == "" ? true : (try(cidrhost("${var.gateway.subnet.min}/0", 0)) != "" ? true : false)) &&
            (var.gateway.subnet.max == "" ? true : (try(cidrhost("${var.gateway.subnet.max}/0", 0)) != "" ? true : false)) &&
            (length([for ip in var.gateway.subnet.intra_dns : (try(cidrhost("${ip}/0", 0)) != "" ? true : false)]) == length(var.gateway.subnet.intra_dns)) &&

            (length([for version in var.gateway.loader.px-versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", version)]) == length(var.gateway.loader.px-versions)) &&
            (length([for version in var.gateway.loader.k8s-versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", version)]) == length(var.gateway.loader.k8s-versions)) &&
            (length([for version in var.gateway.loader.calico-versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)(|[.](0|[1-9][0-9]*))$", version)]) == length(var.gateway.loader.calico-versions)) &&
            (length([for version in var.gateway.loader.csi-versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", version)]) == length(var.gateway.loader.csi-versions))
        )
        error_message = "Gateway: Failed regex check on IPv4 or semantic versioning."
    }
}
