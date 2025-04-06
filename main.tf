
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.89"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_vpc_network" "network" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet1"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  name        = "postgres-vm"
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/id_ed25519.pub")}"
    user-data = <<-EOF
      #cloud-config
      runcmd:
        - apt update && apt install -y docker.io postgresql postgresql-contrib git
        - systemctl enable docker && systemctl start docker
        - usermod -aG docker ubuntu
        - systemctl enable postgresql && systemctl start postgresql
        - sed -i "s/^#listen_addresses = .*/listen_addresses = '*'/g" /etc/postgresql/*/main/postgresql.conf
        - bash -c "echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/*/main/pg_hba.conf"
        - systemctl restart postgresql
        - sudo -u postgres psql -c "CREATE USER myuser WITH PASSWORD 'Amsterdamtoday2025!';"
        - sudo -u postgres psql -c "CREATE DATABASE mydb OWNER myuser;"
        - sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;"
        - git clone https://github.com/SkillfactoryCoding/DEVOPS-praktikum_Docker /tmp/devops
        - mkdir -p /srv/app/conf
        - cp /tmp/devops/web.conf /srv/app/conf/web.conf
        - cp /tmp/devops/web.py /srv/app/web.py
        - sed -i "s/^db_port = .*/db_port = '5432'/" /srv/app/conf/web.conf
        - sed -i "s/^db_user = .*/db_user = 'myuser'/" /srv/app/conf/web.conf
        - sed -i "s/^db_password = .*/db_password = 'Amsterdamtoday2025!'/" /srv/app/conf/web.conf
        - sed -i "s/^db_name = .*/db_name = 'mydb'/" /srv/app/conf/web.conf
        - sed -i "s/^db_host = .*/db_host = '$(hostname -I | awk '{print $1}')'/" /srv/app/conf/web.conf
    EOF
  }
}


output "vm_ip" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "db_user" {
  value = "myuser"
}

output "db_name" {
  value = "mydb"
}
