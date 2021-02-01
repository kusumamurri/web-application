# 1.Create VPC
resource "aws_vpc" "prod" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "web-production"
  }
}

# 2.Create internet gateway
resource "aws_internet_gateway" "prod-gw" {
  vpc_id = aws_vpc.prod.id                        
  tags = {
    Name = "web-production-igw"
  }
}

# 3.create one public subnet per availability zone
resource "aws_subnet" "public" {
  availability_zone       = element(var.azs,count.index)
  cidr_block              = element(var.public_subnets_cidr,count.index)
  count                   = length(var.azs)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.prod.id           
  tags = {
    Name = "subnet-pub-${count.index}"
  }
}

# 4.create one private subnet per availability zone
resource "aws_subnet" "private" {
  availability_zone       = element(var.azs,count.index)   
  cidr_block              = element(var.private_subnets_cidr,count.index)
  count                   = length(var.azs)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.prod.id                
  tags = {
    Name = "subnet-priv-${count.index}"
  }
}

# dynamic list of the public subnets created above
data "aws_subnet_ids" "public" {
  depends_on = [aws_subnet.public]
  vpc_id     = aws_vpc.prod.id                             
}

# dynamic list of the private subnets created above
data "aws_subnet_ids" "private" {
  depends_on = [aws_subnet.private]
  vpc_id     = aws_vpc.prod.id                              
}

# 5. Main route table for vpc
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name = "public_route_table_main"
  }
}

# 6. Add Internet gateway to route table
resource "aws_route" "public" {
  gateway_id             = aws_internet_gateway.prod-gw.id                
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
}

# 7. Associate route table with vpc
resource "aws_main_route_table_association" "public" {
  vpc_id         = aws_vpc.prod.id
  route_table_id = aws_route_table.public.id
}

# 8. Associating route table with all public subnets
resource "aws_route_table_association" "public" {
  count           = length(var.azs)
  #subnet_id      = "${element(data.aws_subnet_ids.public.ids, count.index)}"
  subnet_id = element(tolist(data.aws_subnet_ids.public.ids), count.index)
  route_table_id = aws_route_table.public.id
}

# 9.Creating elastic ip
resource "aws_eip" "prod_eip" {
  count    = length(var.azs)
  vpc      = true
  depends_on = [aws_internet_gateway.prod-gw]
}

# 10. create NAT Gateways
resource "aws_nat_gateway" "prodngw" {
    count    = length(var.azs)
    allocation_id = element(aws_eip.prod_eip.*.id, count.index)
    subnet_id = element(aws_subnet.public.*.id, count.index)
    depends_on = [aws_internet_gateway.prod-gw]
}

# 11.Create private route table for private subnets in all Az's
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.prod.id
  count =length(var.azs)
  tags = {
    Name = "private_subnet_route_table_${count.index}"
  }
}

# 12. Add a nat gateway to each private subnet's route table
resource "aws_route" "private_nat_gateway_route" {
  count = length(var.azs)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on = [aws_route_table.private]
  nat_gateway_id = element(aws_nat_gateway.prodngw.*.id, count.index)
}

