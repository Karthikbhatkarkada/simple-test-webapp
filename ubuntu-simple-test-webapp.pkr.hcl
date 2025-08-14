packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

variable "compartment_ocid" {}
variable "subnet_ocid" {}
variable "availability_domain" {}
variable "binary_path" {}

source "oracle-oci" "ubuntu" {
  compartment_ocid = var.compartment_ocid
  source_image_filter {
    operating_system         = "Canonical Ubuntu"
    operating_system_version = "22.04"
    image_type               = "platform"
    most_recent              = true
  }
  shape               = "VM.Standard.E2.1.Micro"
  subnet_ocid         = var.subnet_ocid
  availability_domain = var.availability_domain
  ssh_username        = "ubuntu"
}

build {
  name    = "ubuntu-nodeapp-oci"
  sources = ["source.oracle-oci.ubuntu"]

  # Upload binary from Jenkins
  provisioner "file" {
    source      = var.binary_path
    destination = "/tmp/webapp"
  }

  # Install binary & systemd
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/webapp /usr/local/bin/webapp",
      "sudo chmod +x /usr/local/bin/webapp",
      "sudo tee /etc/systemd/system/webapp.service > /dev/null <<EOL",
      "[Unit]",
      "Description=Simple Node.js Binary Web App",
      "After=network.target",
      "",
      "[Service]",
      "ExecStart=/usr/local/bin/webapp",
      "Restart=always",
      "User=ubuntu",
      "Environment=PORT=3000",
      "WorkingDirectory=/usr/local/bin",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOL",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable webapp",
      "sudo systemctl start webapp"
    ]
  }
}
