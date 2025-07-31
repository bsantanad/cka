packer {
  required_plugins {
    digitalocean = {
      version = ">=1.0.0"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

source "digitalocean" "ubuntu" {
  image         = "ubuntu-22-04-x64"
  region        = "nyc2"
  size          = "s-1vcpu-2gb"
  ssh_username  = "root" # who we are going to login as
  snapshot_name = "kubeadm-${formatdate("YYYY_MM_DD, hh:mm", timestamp())}"
}

build {
  name = "kubeadm-env"
  sources = [
    "source.digitalocean.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "FOO=hello_world"
    ]
    inline = [
      "echo hello mate",
      "echo \"foo is $FOO\" > example.txt",
    ]
  }
}
