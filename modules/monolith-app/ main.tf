resource "aws_network_interface" "app-server-primary" {
  subnet_id   = var.subnet_id
  private_ips = [var.app_server_ip]
}

resource "aws_instance" "app-server" {
  ami           = var.ami
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.app-server-primary.id
    device_index         = 0
  }
}