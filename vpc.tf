# 1.Create VPC
resource "aws_vpc" "prod" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "web-production"
  }
}

# 2.Internet gateway for the public subnet

resource "aws_internet_gateway" "prod-gw" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name = "web-production-igw"
  }
}

# 3.Elastic IP for NAT Gateway
resource "aws_eip" "prod_eip" {
  count      = length(var.azs)
  vpc        = true
  depends_on = [aws_internet_gateway.prod-gw]
}

#4. Creating NAT gateway
resource "aws_nat_gateway" "prodngw" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.prod_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.prod-gw]
}

# 5. Creating Public subnets for each availability zones
resource "aws_subnet" "public" {
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  count                   = length(var.azs)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.prod.id
  tags = {
    Name = "subnet-pub-${count.index}"
  }
}

#6. Creating Private subnets for each availability zones
resource "aws_subnet" "private" {
  availability_zone       = element(var.azs, count.index)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  count                   = length(var.azs)
  map_public_ip_on_launch = false ###changeto false
  vpc_id                  = aws_vpc.prod.id
  tags = {
    Name = "subnet-priv-${count.index}"
  }
}

#7.Route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.prod.id
  count  = length(var.azs)
  tags = {
    Name = "private_subnet_route_table_${count.index}"
  }
}

# 8.Route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name = "public_route_table_main"
  }
}

# 9. Adding Route for public route table
resource "aws_route" "public" {
  gateway_id             = aws_internet_gateway.prod-gw.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
}

# 10. Adding route for private route table
resource "aws_route" "private_nat_gateway_route" {
  count                  = length(var.azs)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.prodngw.*.id, count.index)
}

# 11. Route table assosciation for each public subnet
resource "aws_route_table_association" "public" {
  count = length(var.azs)
  #subnet_id      = "${element(data.aws_subnet_ids.public.ids, count.index)}"
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# 12. Route table assosciation for each private subnet
resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

