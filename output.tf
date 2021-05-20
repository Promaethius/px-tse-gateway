output "gateway_repo" {
    value = "${var.gateway_subnet_gateway}:8080"
}

output "gateway_registry" {
    value = "${var.gateway_subnet_gateway}"
}

output "gateway_etcd" {
    value = "${var.gateway_subnet_gateway}:2379"
}