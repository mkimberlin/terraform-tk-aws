# More to come...
resource "aws_vpc" "dev" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "ec2-subnet" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "172.16.11.0/24"
  availability_zone = "us-east-2a"
}

module "monolith-app" {
  source        = "../../../modules/monolith-app"
  region        = var.default_region
  ami           = "ami-0cb91c7de36eed2cb" # Ubuntu 24.04 LTS - Free tier eligible
  instance_type = "t2.micro"
  subnet_id = aws_subnet.ec2-subnet.id
  app_server_ip = "172.16.11.100"
}
