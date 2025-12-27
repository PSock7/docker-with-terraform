resource "docker_image" "php-httpd-image" {
  name = "php-httpd:challenge"
  build {
    path       = "${path.module}/lamp_stack/php_httpd"
    dockerfile = "Dockerfile"
    label = {
      challenge = "second"
    }
  }

}

resource "docker_image" "mariadb-image" {
  name = "mariadb:challenge"
  build {
    path       = "${path.module}/lamp_stack/custom_db"
    dockerfile = "Dockerfile"
    label = {
      challenge = "second"
    }
  }

}

resource "docker_network" "private_network" {
  name       = "my_network"
  attachable = true
  labels {
    label = "challenge"
    value = "second"
  }
}

resource "docker_container" "php-httpd" {
  name     = "webserver"
  image    = docker_image.php-httpd-image.name
  hostname = "php-httpd"
  networks = [docker_network.private_network.name]
  labels {
    label = "challenge"
    value = "second"
  }
  volumes {
    host_path      = "/root/code/terraform-challenges/challenge2/lamp_stack/website_content/"
    container_path = "/var/www/html"
  }
  ports {
    internal = 80
    external = 80
  }

}

resource "docker_volume" "mariadb_volume" {
  name = "mariadb-volume"
}

resource "docker_container" "mariadb" {
  name     = "db"
  image    = docker_image.mariadb-image.name
  hostname = "db"
  networks = [docker_network.private_network.name]
  labels {
    label = "challenge"
    value = "second"
  }
  env = [
    "MYSQL_ROOT_PASSWORD=1234",
    "MYSQL_DATABASE=simple-website"
  ]
  volumes {
    volume_name    = docker_volume.mariadb_volume.name
    container_path = "/var/lib/mysql"
  }
  ports {
    internal = 3306
    external = 3306
    ip       = "0.0.0.0"
  }
}

resource "docker_container" "phpmyadmin" {
  name     = "db_dashboard"
  image    = "phpmyadmin/phpmyadmin"
  hostname = "phpmyadmin"
  networks_advanced {
    name = docker_network.private_network.name
  }
  labels {
    label = "challenge"
    value = "second"
  }
  links = [
    docker_container.mariadb.name
  ]
  ports {
    internal = 80
    external = 8081
    ip       = "0.0.0.0"
  }

  depends_on = [docker_container.mariadb]
}
