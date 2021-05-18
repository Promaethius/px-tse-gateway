output "gateway_repo" {
    value = "${var.gateway.subnet.gateway}:8080"
}

output "gateway_registry" {
    value = "${var.gateway.subnet.gateway}"
}

output "gateway_etcd" {
    value = "${var.gateway.subnet.gateway}:2379"
}