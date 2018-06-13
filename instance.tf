variable "remote_ips" {
  description = "Your IP address used to limit SSH access to the host. (ex[\"10.1.2.3/32\"])"
  type = "list"
  default = ["192.168.1.60/32"]
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  tags {
    Name = "pranay-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = "${aws_vpc.my_vpc.id}"
  cidr_block = "172.16.0.0/16"
  availability_zone = "us-west-2a"
  tags {
    Name = "pranay.example"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id = "${aws_subnet.my_subnet.id}"
  private_ips = ["172.16.0.100"]
  tags {
    Name = "primary_network_interface"
  }
}


##Security group##
resource "aws_security_group" "SSH" {
  name        = "SSH"
  description = "Allow SSH only"
  vpc_id      = "${aws_vpc.my_vpc.id}"
}

resource "aws_security_group_rule" "SSH" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.SSH.id}"
}

resource "aws_security_group_rule" "SSH-1" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${var.remote_ips}"]
  security_group_id = "${aws_security_group.SSH.id}"
}

##instance info##
resource "aws_instance" "foo" {
   ami = "ami-e251209a" # us-west-2
   instance_type = "t2.micro"
   key_name = "shopinpal"
   vpc_security_group_ids = ["${aws_security_group.SSH.id}"]

}
