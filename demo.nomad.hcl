job "demo" {
  datacenters = ["dc1"]

  group "demo" {
    count = 2

    network {
      port  "http"{
        to = -1
      }
    }

    service {
      name = "demo-webapp"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Host(`demo.gaia.devusb.us`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      env {
        HTTP_PORT    = "${NOMAD_PORT_http}"
      }

      driver = "docker"

      config {
        image = "mendhak/http-https-echo:27"
        ports = ["http"]
      }
    }
  }
}