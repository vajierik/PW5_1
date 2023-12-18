resource "yandex_lb_target_group" "lamp-lemp" {
  name = "lamp-lemp"
  target {
    subnet_id = yandex_vpc_subnet.subnet1.id
    address   = module.ya_instance_1.internal_ip_address_vm
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet2.id
    address   = module.ya_instance_2.internal_ip_address_vm
  }
}
resource "yandex_lb_network_load_balancer" "nlb-377e5-9a9" {
  name                = "nlb-377e5-9a9"
  deletion_protection = "false"
  listener {
    name = "lb-lamp-lemp"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.lamp-lemp.id
    healthcheck {
      name = "check"
      http_options {
        port = 80
      }
    }
  }
} 