# ----- VPC -----
resource "aws_vpc" "vpc_main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "elon-kiosk-vpc-main"
  }
}

# ----- Public Subnet -----
resource "aws_subnet" "vpc_main_pub_subnet" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "elon-kiosk-public-subnet"
  }
}

resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-igw"
  }
}

resource "aws_route_table" "vpc_main_pub_rtb" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "elon-kiosk-public-rtb"
  }
}

resource "aws_route_table_association" "vpc_main_pub_rtb_assoc" {
  subnet_id      = aws_subnet.vpc_main_pub_subnet.id
  route_table_id = aws_route_table.vpc_main_pub_rtb.id
}

resource "aws_route" "pub_rtb_default" {
  route_table_id         = aws_route_table.vpc_main_pub_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_main.id
}
