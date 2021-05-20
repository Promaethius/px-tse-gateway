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
    description = ""
}

variable "gateway_hostname" {
    type        = string
    default     = "gateway"
    description = ""
}

variable "gateway_ssh" {
    type        = string
    default     = ""
    description = ""
}

variable "gateway_public_ip" {
    type        = string
    default     = "10.15.84.25"
    description = ""
    validation {
        condition = can(try(cidrhost("${var.gateway_public_ip}/0", 0)) != "" ? true : false)
        error_message = "Failed IPv4 check for gateway_public_ip."
    }
}

variable "gateway_public_gateway" {
    type        = string
    default     = "10.15.84.1"
    description = ""
    validation {
        condition = can(try(cidrhost("${var.gateway_public_gateway}/0", 0)) != "" ? true : false)
        error_message = "Failed IPv4 check for gateway_public_gateway."
    }
}

variable "gateway_subnet_gateway" {
    type        = string
    default     = "192.167.0.1"
    description = ""
    validation {
        condition = can(try(cidrhost("${var.gateway_subnet_gateway}/0", 0)) != "" ? true : false)
        error_message = "Failed IPv4 check for gateway_subnet_gateway."
    }
}

variable "gateway_subnet_min" {
    type        = string
    default     = ""
    description = ""
    validation {
        condition = can(var.gateway_subnet_min == "" ? true : (try(cidrhost("${var.gateway_subnet_min}/0", 0)) != "" ? true : false))
        error_message = "Failed IPv4 check for gateway_subnet_min."
    }
}

variable "gateway_subnet_max" {
    type        = string
    default     = ""
    description = ""
    validation {
        condition = can(var.gateway_subnet_max == "" ? true : (try(cidrhost("${var.gateway_subnet_max}/0", 0)) != "" ? true : false))
        error_message = "Failed IPv4 check for gateway_subnet_max."
    }
}

variable "gateway_subnet_intra_dns" {
    type        = list(string)
    default     = ["10.14.250.53", "10.14.250.250"]
    description = ""
    validation {
        condition = can(length([for ip in var.gateway_subnet_intra_dns : (try(cidrhost("${ip}/0", 0)) != "" ? true : false)]) == length(var.gateway_subnet_intra_dns))
        error_message = "Failed IPv4 check for gateway_subnet_intra_dns."
    }
}

variable "gateway_loader_px_versions" {
    type        = list(string)
    default     = ["2.6.0", "2.7.0"]
    description = ""
    validation {
        condition = can(length([for version in var.gateway_loader_px_versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", version)]) == length(var.gateway_loader_px_versions))
        error_message = "Failed Semantic Version check for gateway_loader_px_versions."
    }
}

variable "gateway_loader_k8s_versions" {
    type        = list(string)
    default     = ["1.18.2", "1.20.1"]
    description = ""
    validation {
        condition = can(length([for version in var.gateway_loader_k8s_versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)[.](0|[1-9][0-9]*)$", version)]) == length(var.gateway_loader_k8s_versions))
        error_message = "Failed Semantic Version check for gateway_loader_k8s_versions."
    }
}

variable "gateway_loader_calico_versions" {
    type        = list(string)
    default     = ["3.15"]
    description = ""
    validation {
        condition = can(length([for version in var.gateway_loader_calico_versions : regex("^(0|[1-9][0-9]*)[.](0|[1-9][0-9]*)(|[.](0|[1-9][0-9]*))$", version)]) == length(var.gateway_loader_calico_versions))
        error_message = "Failed Semantic Version check for gateway_loader_calico_versions."
    }
}

variable "gateway_loader_csi_versions" {
    type        = list(string)
    default     = ["2.2.0"]
    description = ""
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
                    "quay.io/prometheus/prometheus:v2.7.1"
                ]
    description = ""
}
