### VPC Setup
resource "aws_vpc" "corevpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.networkname}-${var.location_env}-vpc"
  }
}

### PUBLIC Subnet setup

resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.corevpc
  ] 
  # VPC in which this lives
  vpc_id = aws_vpc.corevpc.id

  # IP Dange for the Public Subnets
  count = length(var.public_subnets)
  cidr_block = element(concat(var.public_subnets, [""]),count.index)
  
  availability_zone = element(concat(var.aws_az, [""]),count.index)
  
  map_public_ip_on_launch = true
  tags = {
      Name = "${var.networkname}-${var.location_env}-subnet-public-${count.index}"
  }
}

####### PRIVATE Subnet setup

resource "aws_subnet" "privSubnet" {
  depends_on = [
    aws_vpc.corevpc,
    aws_subnet.public
  ]
  # VPC in which this lives
  vpc_id = aws_vpc.corevpc.id

  # IP Range for the private subnet
  count = length(var.public_subnets)
  cidr_block = element(concat(var.private_subnets, [""]),count.index)

  availability_zone = element(concat(var.aws_az, [""]),count.index)

  tags = {
    Name = "${var.networkname}-${var.location_env}-subnet-private-${count.index}"
  }
}



### PUBLIC Routes setup --------------------------------------

resource "aws_route_table" "public" {
  depends_on = [
    aws_vpc.corevpc,
    aws_internet_gateway.intgw
  ]
  vpc_id = aws_vpc.corevpc.id

  tags = {
    Name = "${var.networkname}-${var.location_env}-route"
  }
}

# ROUTING TABLE SETUP ---------------------------------------
resource "aws_route" "public_intgw_route" {
  depends_on = [
    aws_vpc.corevpc,
    aws_subnet.public,
    aws_subnet.privSubnet
  ]
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.intgw.id

  timeouts {
    create = "5m"
  }
}
# Association for the subnets
resource "aws_route_table_association" "public_rt_association" {
  count = length(var.public_subnets)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

## Internet gateway setup -----------------------------------
resource "aws_internet_gateway" "intgw" {
  depends_on = [
    aws_vpc.corevpc,
    aws_subnet.public,
    aws_subnet.privSubnet
  ]
  vpc_id = aws_vpc.corevpc.id
  tags = {
    Name = "${var.networkname}-${var.location_env}-intgw"
  }
}

### ----------- Generation of Multiple NATs required ( one per AZ ) for throughput ------------

## Elastic IP For the NAT Gateway AZ A
resource "aws_eip" "NAT_Gateway_EIP_A" {
  depends_on = [
    aws_route_table_association.public_rt_association
  ]
  vpc = true
  tags = {
    Name = "${var.networkname}-${var.location_env}-eipA"
  }
}
## Elastic IP For the NAT Gateway AZ B
resource "aws_eip" "NAT_Gateway_EIP_B" {
  depends_on = [
    aws_route_table_association.public_rt_association
  ]
  vpc = true
  tags = {
    Name = "${var.networkname}-${var.location_env}-eipB"
  }
}
## Elastic IP For the NAT Gateway AZ C
resource "aws_eip" "NAT_Gateway_EIP_C" {
  depends_on = [
    aws_route_table_association.public_rt_association
  ]
  vpc = true
  tags = {
    Name = "${var.networkname}-${var.location_env}-eipC"
  }
}

## NAT Gateway for the Public Subnet A
resource "aws_nat_gateway" "NAT_Public_A" {
  depends_on = [
    aws_eip.NAT_Gateway_EIP_A
  ]
  # Add EIP to NAT Gateway
  allocation_id = aws_eip.NAT_Gateway_EIP_A.id
  # Allocate to first subnet
  subnet_id = element(aws_subnet.public.*.id, 0)
  tags = {
    Name = "${var.networkname}-${var.location_env}-NATgatewayA"
  }
}
## NAT Gateway for the Public Subnet B
resource "aws_nat_gateway" "NAT_Public_B" {
  depends_on = [
    aws_eip.NAT_Gateway_EIP_B
  ]
  # Add EIP to NAT Gateway
  allocation_id = aws_eip.NAT_Gateway_EIP_B.id
  # Allocate to second subnet
  subnet_id = element(aws_subnet.public.*.id, 1)
  tags = {
    Name = "${var.networkname}-${var.location_env}-NATgatewayB"
  }
}
## NAT Gateway for the Public Subnet C
resource "aws_nat_gateway" "NAT_Public_C" {
  depends_on = [
    aws_eip.NAT_Gateway_EIP_C
  ]
  # Add EIP to NAT Gateway
  allocation_id = aws_eip.NAT_Gateway_EIP_C.id
  # Allocate to third subnet
  subnet_id = element(aws_subnet.public.*.id, 2)
  tags = {
    Name = "${var.networkname}-${var.location_env}-NATgatewayC"
  }
}

############# VPC Gateway ( for access to other VPC services & cost reduction )
resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.corevpc.id
  service_name = "com.amazonaws.eu-west-2.s3"
  tags = {
    Name = "${var.networkname}-${var.location_env}-vpc-endpoint"
  }
}