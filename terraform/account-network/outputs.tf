output "vpc_id" {
    description = "VPC ID"
    value = aws_vpc.corevpc.id
}
output "public_subnet_0" {
    description = "Public Subnet 0"
    value = aws_subnet.public[0].id
}
output "public_subnet_1" {
    description = "Public Subnet 1"
    value = aws_subnet.public[1].id
}
output "public_subnet_2" {
    description = "Public Subnet 2"
    value = aws_subnet.public[2].id
}
output "private_subnet_0" {
    description = "Private Subnet 0"
    value = aws_subnet.privSubnet[0].id
}
output "private_subnet_1" {
    description = "Private Subnet 1"
    value = aws_subnet.privSubnet[1].id
}
output "private_subnet_2" {
    description = "Private Subnet 2"
    value = aws_subnet.privSubnet[2].id
}