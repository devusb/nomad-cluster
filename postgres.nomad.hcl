job "postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres" {
    count = 1

    volume "postgres" {
      type      = "csi"
      read_only = false

      # nfs
      source          = "postgres"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    network {
      port "db" {
        to = -1
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "postgres" {
      driver = "docker"

      volume_mount {
        volume      = "postgres"
        destination = "/pgdata"
        read_only   = false
      }

      env {
        POSTGRES_PASSWORD = "postgres"
        PGDATA            = "/pgdata"
      }

      config {
        image = "postgres"
        ports = ["db"]
        args = [ "-p", "${NOMAD_PORT_db}" ]
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name = "postgres"
        port = "db"

        tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.postgres.rule=HostSNI(`*`)",
          "traefik.tcp.routers.postgres.tls=false",
          "traefik.tcp.routers.postgres.entrypoints=postgres",
        ]
      }
    }
  }
}