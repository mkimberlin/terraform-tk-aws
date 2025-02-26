# More to come...
resource "aws_vpc" "dev" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "ec2-subnet" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "172.16.11.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_network_interface" "app-server-primary" {
  subnet_id   = aws_subnet.ec2-subnet.id
  private_ips = ["172.16.11.100"]
}

resource "aws_instance" "app-server" {
  ami           = "ami-0cb91c7de36eed2cb" # Ubuntu 24.04 LTS - Free tier eligible
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.app-server-primary.id
    device_index         = 0
  }
}
