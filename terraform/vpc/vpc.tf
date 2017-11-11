# The provider here is aws but it can be other provider
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "plivo_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "PlivoVPC"
  }
}

# Create a way out to the internet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.plivo_vpc.id}"
  tags {
        Name = "InternetGateway"
    }
}

# Public route as way out to the internet
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.plivo_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
#   tags {
#         Name = "Public route table"
#   }
}


# Create the private route table
resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.plivo_vpc.id}"

    tags {
        Name = "Private route table"
    }
}

# Create private route
resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

# Create a subnet in the AZ ap-south-1a
resource "aws_subnet" "subnet_ap_south_1a" {
  vpc_id                  = "${aws_vpc.plivo_vpc.id}"
  cidr_block              = "11.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = {
  	Name =  "Subnet az 1a"
  }
}

# Create a subnet in the AZ ap-south-1b
resource "aws_subnet" "subnet_ap_south_1b" {
  vpc_id                  = "${aws_vpc.plivo_vpc.id}"
  cidr_block              = "11.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
  	Name =  "Subnet az 1b"
  }
}

# Create an EIP for the natgateway
resource "aws_eip" "nat" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}


# Create a nat gateway and it will depend on the internet gateway creation
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.subnet_ap_south_1a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

# Associate subnet subnet_ap_south_1a to public route table
resource "aws_route_table_association" "subnet_ap_south_1a_association" {
    subnet_id = "${aws_subnet.subnet_ap_south_1a.id}"
    route_table_id = "${aws_vpc.plivo_vpc.main_route_table_id}"
}

# Associate subnet subnet_ap_south_1b to private route table
resource "aws_route_table_association" "subnet_ap_south_1b_association" {
    subnet_id = "${aws_subnet.subnet_ap_south_1b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

# route 53 zone 
resource "aws_route53_zone" "plivo_zone" {
  name   = "test.plivo"
  vpc_id = "${aws_vpc.plivo_vpc.id}"
}
