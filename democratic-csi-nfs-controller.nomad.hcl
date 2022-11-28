job "democratic-csi-nfs-controller" {
  datacenters = ["dc1"]

  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "docker.io/democraticcsi/democratic-csi:latest"

        entrypoint = ["/bin/sh", "-c"]
        command    = "mkdir -p /storage && mount -t nfs gaia0:/var/lib/exports/nomad-volumes /storage -o nolock && bin/democratic-csi --csi-version=1.5.0 --csi-name=org.democratic-csi.nfs --driver-config-file=${NOMAD_TASK_DIR}/driver-config-file.yaml --log-level=debug --csi-mode=controller --server-socket=/csi/csi.sock"
        privileged = true
      }

      template {
        destination = "${NOMAD_TASK_DIR}/driver-config-file.yaml"

        data = <<EOH
driver: nfs-client
instance_id:
nfs:
  shareHost: gaia0
  shareBasePath: "/var/lib/exports/nomad-volumes"
  # shareHost:shareBasePath should be mounted at this location in the controller container
  controllerBasePath: "/storage"
  dirPermissionsMode: "0777"
  dirPermissionsUser: root
  dirPermissionsGroup: root
EOH
      }

      csi_plugin {
        # must match --csi-name arg
        id        = "org.democratic-csi.nfs"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}