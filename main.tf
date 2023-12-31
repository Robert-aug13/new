provider "null" {}

resource "null_resource" "disable_ufw_swap" {
  connection {
    type        = "ssh"
    host        = "3.143.212.215"
    user        = "ubuntu"
    private_key = file("C:/Users/Robert/Downloads/micro-new.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ufw disable",
      "sudo swapoff -a",
      "sudo sed -i '/swap/d' /etc/fstab",
    ]
  }
}

resource "null_resource" "install_microk8s" {
  depends_on = [null_resource.disable_ufw_swap]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "3.143.212.215"
      user        = "ubuntu"
      private_key = file("C:/Users/Robert/Downloads/micro-new.pem")
    }
    inline = [
      "timeout 30 bash -c 'while true; do sudo snap install microk8s --classic; [ $? -eq 0 ] && break; sleep 1; done'",
    ]
  }

  provisioner "remote-exec" {
    when    = destroy
    connection {
      type        = "ssh"
      host        = "3.143.212.215"
      user        = "ubuntu"
      private_key = file("C:/Users/Robert/Downloads/micro-new.pem")
    }
    inline = [
      "yes | sudo microk8s reset",
    ]
  }
}


resource "null_resource" "enable_microk8s_dashboard" {
  depends_on = [null_resource.install_microk8s]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "18.217.119.180"
      user        = "ubuntu"
      private_key = file("C:/Users/Robert/Downloads/micro-new.pem")
    }
    inline = [
      "microk8s enable dashboard",
    ]
  }

}


resource "null_resource" "enable_microk8s_metallb" {
  depends_on = [null_resource.install_microk8s]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "18.217.119.180"
      user        = "ubuntu"
      private_key = file("C:/Users/Robert/Downloads/micro-new.pem")
    }
    inline = [
      "microk8s enable metallb:${var.metallb_ip_range[0]}",
    ]
  }
}



variable.tf

variable "metallb_ip_range" {
  description = "The IP range for MetalLB"
  type        = list(any)
  default     = ["172.31.0.222-172.31.0.240"]  # Modify this with your desired IP range
}