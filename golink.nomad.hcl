job "golink" {
  datacenters = ["dc1"]

  group "golink" {
    count = 1

    volume "golink" {
      type      = "csi"
      read_only = false

      # nfs
      source          = "golink"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    task "golink" {
      driver = "docker"

      template {
        data = <<EOH
TS_AUTHKEY="{{with secret "secret/data/tailscale"}}{{.Data.data.AUTH_KEY}}{{end}}"
EOH

        destination = "secrets/file.env"
        env         = true
      }

      volume_mount {
        volume      = "golink"
        destination = "/root"
        read_only   = false
      }

      config {
        image = "devusb/golink:latest"
      }
      vault {
        policies = ["tailscale"]

        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }
    }
  }
}