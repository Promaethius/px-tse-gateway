variable "vsphere" {
    type        = object({
        user       = string
        password   = string
        server     = string
        host       = string
        datastore  = string
        datacenter = string
        folderpath = string
    })
    default     = {
        user       = ""
        password   = ""
        server     = ""
        host       = ""
        datacenter = ""
        datastore  = ""
        folderpath = ""
    }
    description = <<EOF
vSphere Configuration:
user: vSphere username
password: vSphere password
server: vSphere server endpoint
host: ESXi host within vSphere
datacenter: vSphere datacenter containing host
datastore: backing datastore attached to host
folderpath: underneath datacenter, folder path to host
    EOF
}

variable "gateway_hostname" {
    type        = string
    default     = "gateway"
    description = "Gateway VM Hostname"
}

variable "gateway_ssh" {
    type        = string
    default     = ""
    description = "Public SSH key. If one is not provided, then ~/.ssh/id_rsa.pub is scanned."
}

variable "gateway_public_ip" {
    type        = string
    default     = ""
    description = "Static IP for gateway VM within vSphere."
    validation {
        condition = can(try(cidrhost("${var.gateway_public_ip}/0", 0)) != "" ? true : false)
        error_message = "Failed IPv4 check for gateway_public_ip."
    }
}

variable "gateway_public_gateway" {
    type        = string
    default     = ""
    description = "Outgoing gateway for traffic from gateway VM."
    validation {
        condition = can(try(cidrhost("${var.gateway_public_gateway}/0", 0)) != "" ? true : false)
        error_message = "Failed IPv4 check for gateway_public_gateway."
    }
}

variable "gateway_subnet_gateway" {
    type        = string
    default     = "192.167.0.1"
    description = "Subnet gateway IP. x.x.x.1 is required."
    validation {
        condition = can(try(cidrhost("${var.gateway_subnet_gateway}/0", 0)) != "" ? true : false)
        error_message = "Failed IPv4 check for gateway_subnet_gateway."
    }
}

variable "gateway_subnet_min" {
    type        = string
    default     = ""
    description = "Min IPv4 address to lease to subnet from DHCP. Default is x.x.x.2"
    validation {
        condition = can(var.gateway_subnet_min == "" ? true : (try(cidrhost("${var.gateway_subnet_min}/0", 0)) != "" ? true : false))
        error_message = "Failed IPv4 check for gateway_subnet_min."
    }
}

variable "gateway_subnet_max" {
    type        = string
    default     = ""
    description = "Max IPv4 address to lease to subnet from DHCP. Default is x.x.x.249"
    validation {
        condition = can(var.gateway_subnet_max == "" ? true : (try(cidrhost("${var.gateway_subnet_max}/0", 0)) != "" ? true : false))
        error_message = "Failed IPv4 check for gateway_subnet_max."
    }
}

variable "gateway_subnet_intra_dns" {
    type        = list(string)
    default     = [""]
    description = "List of IPs that point to internal nameservers."
    validation {
        condition = can(length([for ip in var.gateway_subnet_intra_dns : (try(cidrhost("${ip}/0", 0)) != "" ? true : false)]) == length(var.gateway_subnet_intra_dns))
        error_message = "Failed IPv4 check for gateway_subnet_intra_dns."
    }
}

variable "gateway_loader_px_versions" {
    type        = list(string)
    default     = ["2.6.0", "2.7.0"]
    description = "Portworx versions to load into registry."
    validation {
        condition = can(length([for version in var.gateway_loader_px_versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", version)]) == length(var.gateway_loader_px_versions))
        error_message = "Failed Semantic Version check for gateway_loader_px_versions."
    }
}

variable "gateway_loader_k8s_versions" {
    type        = list(string)
    default     = ["1.18.2", "1.20.1"]
    description = "Kubernetes component versions to load into registry."
    validation {
        condition = can(length([for version in var.gateway_loader_k8s_versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", version)]) == length(var.gateway_loader_k8s_versions))
        error_message = "Failed Semantic Version check for gateway_loader_k8s_versions."
    }
}

variable "gateway_loader_calico_versions" {
    type        = list(string)
    default     = ["3.15"]
    description = "Calico versions to load into registry."
    validation {
        condition = can(length([for version in var.gateway_loader_calico_versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)(|[.](0|[1-9][0-9]*))$", version)]) == length(var.gateway_loader_calico_versions))
        error_message = "Failed Semantic Version check for gateway_loader_calico_versions."
    }
}

variable "gateway_loader_csi_versions" {
    type        = list(string)
    default     = ["2.2.0"]
    description = "vSphere Container Storage Interface versions to load into registry."
    validation {
        condition = can(length([for version in var.gateway_loader_csi_versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", version)]) == length(var.gateway_loader_csi_versions))
        error_message = "Failed Semantic Version check for gateway_loader_csi_versions."
    }
}

variable "gateway_loader_extras" {
    type        = list(string)
    default     = [
                    "plndr/kube-vip:0.3.2",
                    "quay.io/coreos/prometheus-operator:v0.34.0",
                    "quay.io/coreos/prometheus-config-reloader:v0.34.0",
                    "quay.io/coreos/configmap-reload:v0.0.1",
                    "quay.io/prometheus/prometheus:v2.7.1",
                    "gcr.io/cloud-provider-vsphere/cpi/release/manager:v1.18.1"
                ]
    description = "Additional container images to load into registry."
}
