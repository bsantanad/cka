terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
variable "ssh_public_key_path" {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_droplet_snapshot" "kube-snapshot" {
  name_regex  = "kubeadm-*"
  region      = "nyc2"
  most_recent = true
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = file(var.ssh_public_key_path)
}

resource "digitalocean_droplet" "control-plane" {
  image    = data.digitalocean_droplet_snapshot.kube-snapshot.id
  name     = "control-plane"
  region   = "nyc2"
  size     = "s-1vcpu-2gb"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
  # the user `marx` comes from the snapshot created with packer
  user_data = <<-EOF
              #!/bin/bash
              cp /root/.ssh/authorized_keys /home/marx/.ssh/authorized_keys
              chown marx:marx /home/marx/.ssh/authorized_keys
              EOF
}

resource "digitalocean_droplet" "worker" {
  image     = data.digitalocean_droplet_snapshot.kube-snapshot.id
  name      = "worker"
  region    = "nyc2"
  size      = "s-1vcpu-2gb"
  ssh_keys  = [digitalocean_ssh_key.default.fingerprint]
  user_data = <<-EOF
              #!/bin/bash
              cp /root/.ssh/authorized_keys /home/marx/.ssh/authorized_keys
              chown marx:marx /home/marx/.ssh/authorized_keys
              EOF
}

