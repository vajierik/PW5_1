terraform {
  required_version = ">=1.5.5"
  required_providers {
    yandex = {
      source                = "yandex-cloud/yandex"
      version               = "0.100.0"
      configuration_aliases = [yandex.zone_b]
    }

  }
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "vajierik-bucket"
    region     = "ru-central1-a"
    key        = "sfstate/lemp-lamp.tfstate"
    access_key = "YCAJE4HX9KGVI_d_QGTwoIuRT"
    secret_key = "YCNxnGFcVQ1CSO4-pvoFo-X9gYpM2i1_WSsu8p7u"

    skip_region_validation      = true
    skip_credentials_validation = true
    #skip_requesting_account_id  = true # This option is required to describe backend for Terraform version 1.6.1 or higher.
    #skip_s3_checksum            = true # This option is required to describe backend for Terraform version 1.6.3 or higher.

  }
}
provider "yandex" {
  token     = "y0_AgAAAAAH33B6AATuwQAAAAD0A7mP6OZQo1auSE6H3UXp0uHXF0pqdrY"
  cloud_id  = "b1gqkcvoua07qmolears"
  folder_id = "b1g35gfqsn2ee0jmmuvd"
  zone      = "ru-central1-a"

}
provider "yandex" {
  alias     = "zone_b"
  token     = "y0_AgAAAAAH33B6AATuwQAAAAD0A7mP6OZQo1auSE6H3UXp0uHXF0pqdrY"
  cloud_id  = "b1gqkcvoua07qmolears"
  folder_id = "b1g35gfqsn2ee0jmmuvd"
  zone      = "ru-central1-b"
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}


module "ya_instance_1" {
  source                = "./modules/instance"
  instance_family_image = "lemp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet1.id

}

module "ya_instance_2" {
  source                = "./modules/instance"
  instance_family_image = "lamp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet2.id
  providers = {
    yandex = yandex.zone_b
  }

}
#resource "yandex_lb_target_group" "lamp-lemp" {
# name = "lamp-lemp"
#target {

# address   = module.ya_instance_2.internal_ip_address_vm
#subnet_id = yandex_vpc_subnet.subnet2.id

#  }

# target {
#  subnet_id = yandex_vpc_subnet.subnet1.id
# address   = module.ya_instance_1.internal_ip_address_vm
#}
#}

#resource "yandex_lb_network_load_balancer" "nlb-377e5-9a9" {
#  name                = "nlb-377e5-9a9"
#  deletion_protection = "false"
#  listener {
#    name = "lb-lamp-lemp"
#    port = 80
#    external_address_spec {
#      ip_version = "ipv4"
#    }
#  }
#  attached_target_group {
#    target_group_id = yandex_lb_target_group.lamp-lemp.id
#    healthcheck {
#      name = "check"
#      http_options {
#        port = 80
#path = "<адрес_URL,_по_которому_будут_выполняться_проверки>"
#      }
#   }
# }
#}