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
  compartment_ocid     = var.compartment_ocid
  subnet_ocid          = var.subnet_ocid
  availability_domain  = var.availability_domain
  shape                = "VM.Standard.E2.1.Micro"
  base_image_ocid      = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaafs7imfvcicboqisaisiz5bbpuzbg5gicwjwvyhnhsvdaowuc3w4q"
  ssh_username         = "ubuntu"
  ssh_private_key_file = "/var/lib/jenkins/.oci/oci_api_key.pem"
}


build {
  name    = "ubuntu-simple-test-webapp-oci"
  sources = ["source.oracle-oci.ubuntu"]

  # Upload binary from Jenkins
  provisioner "file" {
    source      = var.binary_path
    destination = "/tmp/testwebapp"
  }

  # Install binary & systemd
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/testwebapp /usr/local/bin/testwebapp",
      "sudo chmod +x /usr/local/bin/testwebapp",
      "sudo tee /etc/systemd/system/testwebapp.service > /dev/null <<EOL",
      "[Unit]",
      "Description=Simple Node.js Binary Web App",
      "After=network.target",
      "",
      "[Service]",
      "ExecStart=/usr/local/bin/testwebapp",
      "Restart=always",
      "User=ubuntu",
      "Environment=PORT=3000",
      "WorkingDirectory=/usr/local/bin",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOL",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable testwebapp",
      "sudo systemctl start testwebapp"
    ]
  }
}
