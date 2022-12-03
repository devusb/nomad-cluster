type         = "csi"
id           = "golink"
name         = "golink"
plugin_id    = "org.democratic-csi.nfs"
capacity_min = "1GiB"
capacity_max = "1GiB"

capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

mount_options {
  mount_flags = ["noatime", "nfsvers=4"]
}