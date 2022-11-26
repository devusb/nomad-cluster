job "rpilocator" {
  datacenters = ["dc1"]

  group "rpilocator" {
    count = 1

    task "rpilcator" {
      driver = "docker"
      env {
        CHECK_DELTA      = "0"
        FEED_URL         = "https://rpilocator.com/feed.rss"
        REFRESH_INTERVAL = "1"
      }

      template {
        data = <<EOH
      PUSHOVER_TOKEN="{{with secret "secret/data/rss-pushover/rpilocator"}}{{.Data.data.token}}{{end}}"
      PUSHOVER_USER="{{with secret "secret/data/rss-pushover/rpilocator"}}{{.Data.data.user}}{{end}}"
      EOH

        destination = "secrets/file.env"
        env         = true
      }

      config {
        image = "devusb/go-rss-pushover:latest"
      }
      vault {
        policies = ["rss-pushover"]

        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }
    }
  }
}